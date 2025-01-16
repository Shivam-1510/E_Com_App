using API.Data.IRepository;
using API.Models.UserModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;

using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace API.Controllers.UserControllers
{
    [ApiController]
    [Route("userrole")]
    [Authorize(Policy = SD.IsAccess)]
    public class UserRoleController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public UserRoleController(IUnitOfWork iunitofwork)
        {
            _iunitofwork = iunitofwork;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var userRoleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirstValue(ClaimTypes.Role));

                if (userRoleInClaim.RoleLevel == RoleLevels.SUPREME)
                    return Ok(await _iunitofwork.UserRole.GetAllAsync());
                else
                    return Ok(await _iunitofwork.UserRole.GetAllAsync(d => d.RoleLevel < userRoleInClaim.RoleLevel));

            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("role")]
        [Authorize(Policy = SD.SupremeLevel)]
        public async Task<IActionResult> GetRole(string RoleCode)
        {
            try
            {
                if (RoleCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedRoleCode = _iunitofwork.UserRole.DecrypteBase64(RoleCode);

                var userRoleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirstValue(ClaimTypes.Role));
                var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == decryptedRoleCode);

                if (requiredRole == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                if (userRoleInClaim.RoleLevel != RoleLevels.SUPREME && requiredRole.RoleLevel >= userRoleInClaim.RoleLevel)
                    return BadRequest(new { message = ValidationMessages.NoAccess });
                else
                    return Ok(requiredRole);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPost("create")]
        [Authorize(Policy = SD.SupremeLevel)]
        public async Task<IActionResult> CreateRole([FromBody] UserRole UserRole)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.UserRole.FirstOrDefaultAsync(x => x.RoleName == UserRole.RoleName);
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    var supremeLevelRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleLevel == RoleLevels.SUPREME);
                    if (supremeLevelRole != null && UserRole.RoleLevel == RoleLevels.SUPREME)
                        return BadRequest(new { message = ValidationMessages.NoAccess });

                    UserRole role = new UserRole() 
                    { 
                        RoleCode = _iunitofwork.UserRole.GenrateUniqueCode(),
                        RoleName = UserRole.RoleName,
                        RoleLevel = UserRole.RoleLevel
                    };
                    if (UserRole.RoleName == SD.INDIVIDUAL)
                    {
                        role.RoleCode = SD.INDIVIDUAL;
                        role.RoleLevel = RoleLevels.BASE;
                    }
                    await _iunitofwork.UserRole.AddAsync(role);
                    return Ok(new { message = ValidationMessages.Created });

                }
                else
                    return BadRequest(new { message = ValidationMessages.BadRequest });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new
                {
                    message = ValidationMessages.Default,
                    exception = Ex
                });
            }
        }

        [HttpPut("update")]
        [Authorize(Policy = SD.SupremeLevel)]
        public async Task<IActionResult> UpdateRole([FromBody] UserRole UserRole)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.UserRole.GetAsync(UserRole.RoleCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    var indbExists = await _iunitofwork.UserRole.FirstOrDefaultAsync(x => x.RoleName == UserRole.RoleName && x.Id != indb.Id);
                    if (indbExists != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    var supremeLevelRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleLevel == RoleLevels.SUPREME);
                    if (supremeLevelRole != null && UserRole.RoleLevel == RoleLevels.SUPREME && UserRole.RoleCode != supremeLevelRole.RoleCode)
                        return BadRequest(new { message = ValidationMessages.NoAccess });


                    await _iunitofwork.UserRole.UpdateAsync(indb.RoleCode, async entity =>
                    {
                        entity.RoleName = UserRole.RoleName;
                        entity.RoleLevel = UserRole.RoleLevel;
                        await Task.CompletedTask;
                    });
                    return Ok(new { message = ValidationMessages.Updated });
                }
                else
                    return BadRequest(new { message = ValidationMessages.BadRequest });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpDelete("delete")]
        [Authorize(Policy = SD.SupremeLevel)]
        public async Task<IActionResult> DeleteRole(string RoleCode)
        {
            try
            {
                if (RoleCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedRoleCode = _iunitofwork.UserRole.DecrypteBase64(RoleCode);
                var indb = await _iunitofwork.UserRole.GetAsync(decryptedRoleCode);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var usersshave = await _iunitofwork.RoleAccess.FirstOrDefaultAsync(d => d.RoleCode == indb.RoleCode);
                var menushave = await _iunitofwork.MenuAccess.FirstOrDefaultAsync(d => d.RoleCode == indb.RoleCode);
                var routesshave = await _iunitofwork.RouteAccess.FirstOrDefaultAsync(d => d.RoleCode == indb.RoleCode);

                if (usersshave != null || menushave != null || routesshave != null)
                    return BadRequest(new { message = ValidationMessages.ObjectDepends });

                await _iunitofwork.UserRole.RemoveAsync(decryptedRoleCode);
                return Ok(new { message = ValidationMessages.Deleted });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

    }
}
