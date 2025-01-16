using API.Data.IRepository;
using API.Models.UserModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace API.Controllers.UserControllers
{
    [Route("user")]
    [ApiController]
    public class UserController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public UserController(IUnitOfWork unitofwork)
        {
            _iunitofwork = unitofwork;
        }

        [HttpGet("users")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetUsers(string RoleCode)
        {
            try
            {
                var userRoleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirst(ClaimTypes.Role).Value);

                var usersToRemove = new List<RoleAccess>();

                if (RoleCode == null)
                {
                    var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleLevel == RoleLevels.PRIMARY);

                    var users = (await _iunitofwork.RoleAccess.GetAllAsync(x => x.RoleCode == requiredRole.RoleCode, includeProperties: "User,UserRole")).ToList();
                    foreach (var user in users)
                    {
                        var rolesindb = await _iunitofwork.RoleAccess.GetAllAsync(u => u.UserCode == user.UserCode, includeProperties: "User,UserRole");
                        if (rolesindb.Any(r => userRoleInClaim.RoleLevel != RoleLevels.SUPREME && r.UserRole.RoleLevel >= userRoleInClaim.RoleLevel))
                            usersToRemove.Add(user); // Add user to remove list
                    }
                    foreach (var user in usersToRemove)
                    {
                        users.Remove(user);
                    }
                    return Ok(users);
                }
                else
                {
                    var decryptedRoleCode = _iunitofwork.User.DecrypteBase64(RoleCode);
                    var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == decryptedRoleCode);

                    if (userRoleInClaim.RoleLevel != RoleLevels.SUPREME && requiredRole.RoleLevel >= userRoleInClaim.RoleLevel)
                        return BadRequest(new { message = ValidationMessages.NoAccess });

                    var users = (await _iunitofwork.RoleAccess.GetAllAsync(x => x.RoleCode == requiredRole.RoleCode, includeProperties: "User,UserRole")).ToList();
                    foreach (var user in users)
                    {
                        var rolesindb = await _iunitofwork.RoleAccess.GetAllAsync(u => u.UserCode == user.UserCode, includeProperties: "User,UserRole");
                        if (rolesindb.Any(r => userRoleInClaim.RoleLevel != RoleLevels.SUPREME && r.UserRole.RoleLevel >= userRoleInClaim.RoleLevel))
                            usersToRemove.Add(user); // Add user to remove list
                    }
                    foreach (var user in usersToRemove)
                    {
                        users.Remove(user);
                    }
                    return Ok(users);

                }
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("user")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetUser(string UserCode, string RoleCode)
        {
            try
            {
                var userRoleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirst(ClaimTypes.Role).Value);
                if (RoleCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedroleCode = _iunitofwork.User.DecrypteBase64(RoleCode);
                var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == decryptedroleCode);

                if (requiredRole == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                else if (userRoleInClaim.RoleLevel != RoleLevels.SUPREME && requiredRole.RoleLevel >= userRoleInClaim.RoleLevel)
                    return BadRequest(new { message = ValidationMessages.NoAccess });
                else
                {
                    if (UserCode == null)
                    {
                        return BadRequest(new { message = ValidationMessages.BadRequest });
                    }
                    var decryptedUserCode = _iunitofwork.User.DecrypteBase64(UserCode);

                    var user = await _iunitofwork.RoleAccess.FirstOrDefaultAsync(filter: d => d.UserCode == decryptedUserCode && d.RoleCode == requiredRole.RoleCode, includeProperties: "User,UserRole");

                    if (user == null)
                        return NotFound(new { message = ValidationMessages.NotFound });
                    else
                    {
                        var rolesindb = await _iunitofwork.RoleAccess.GetAllAsync(u => u.UserCode == user.UserCode, includeProperties: "User,UserRole");

                        if (rolesindb.Any(r => userRoleInClaim.RoleLevel != RoleLevels.SUPREME && r.UserRole.RoleLevel >= userRoleInClaim.RoleLevel))

                            return BadRequest(new { message = ValidationMessages.NoAccess });

                        return Ok(user);
                    }
                }
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }

        }

        [Authorize]
        [HttpGet("userbyclaim")]
        public async Task<IActionResult> GetUserByClaim()
        {
            try
            {
                var userInClaim = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == User.FindFirst(ClaimTypes.SerialNumber).Value);

                var rolesindb = await _iunitofwork.RoleAccess.GetAllAsync(u => u.UserCode == userInClaim.UserCode && u.AccessToRole == true, includeProperties: "User,UserRole");

                List<UserRole> roles = new List<UserRole>();

                foreach (var role in rolesindb)
                {
                    var userRole = role.UserRole;
                    roles.Add(userRole);
                }

                UserInClaimVM user = new UserInClaimVM()
                {
                    User = userInClaim,
                    UserRoles = roles
                };
                return Ok(user);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

    }
}
