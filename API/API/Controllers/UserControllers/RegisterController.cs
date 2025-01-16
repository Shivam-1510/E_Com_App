using API.Data.IRepository;
using API.Models.UserModels;
using API.Models.UserTables;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace API.Controllers.UserControllers
{
    [Route("register")]
    [ApiController]
    public class RegisterController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public RegisterController(IUnitOfWork unitofwork)
        {
            _iunitofwork = unitofwork;
        }

        [HttpPost("individual")]
        public async Task<IActionResult> RegisterIndividual([FromBody] RegisterVM user)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == SD.INDIVIDUAL);

                    if (requiredRole == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    var isuniqueuser = await _iunitofwork.User.IsUniqueUser(user.MobileNumber);
                    if (!isuniqueuser)
                        return BadRequest(new { message = ValidationMessages.Exists });
                    User adduser = new User()
                    {
                        UserCode = _iunitofwork.User.GenrateUniqueCode(),
                        Name = user.Name,
                        Password = user.Password,
                        MobileNumber = user.MobileNumber,
                        IsMobileVerified = false,
                        IsActive = false,
                        CreatedOn = DateTime.UtcNow
                    };
                    adduser.CreatedBy = adduser.Name + "/" + adduser.UserCode;
                    RoleAccess userrole = new RoleAccess
                    {
                        AccessId = _iunitofwork.RoleAccess.GenrateUniqueCode(),
                        UserCode = adduser.UserCode,
                        RoleCode = requiredRole.RoleCode,
                        AccessToRole = false
                    };
                    await _iunitofwork.User.RegisterUser(adduser);
                    await _iunitofwork.RoleAccess.AddAsync(userrole);
                    return Ok(new { message = ValidationMessages.Created });
                }
                return BadRequest(new { message = ValidationMessages.BadRequest });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpDelete("verifyindividual")]
        public async Task<IActionResult> VerifyIndividualUser(string UserCode)
        {
            try
            {
                if (UserCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedUserCode = _iunitofwork.User.DecrypteBase64(UserCode);

                var indb = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == decryptedUserCode);

                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var inDbRole = await _iunitofwork.RoleAccess.FirstOrDefaultAsync(ra => ra.UserCode == indb.UserCode && ra.RoleCode == SD.INDIVIDUAL);

                if (inDbRole == null)
                {
                    return BadRequest(new { message = ValidationMessages.NoAccess });
                }
                await _iunitofwork.User.UpdateAsync(indb.UserCode, async entity =>
                {
                    entity.IsActive = true;
                    entity.IsMobileVerified = true;
                    await Task.CompletedTask;
                });
                await _iunitofwork.RoleAccess.UpdateAsync(inDbRole.AccessId, async entity =>
                {
                    entity.AccessToRole = true;
                    await Task.CompletedTask;
                });

                return Ok(new { message = ValidationMessages.Deleted });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }


        [HttpPost("registeruser")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> RegisterUser([FromBody] RegisterVM user, string RoleCode)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var userRoleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirstValue(ClaimTypes.Role));
                    var userInClaim = await _iunitofwork.User.FirstOrDefaultAsync(x => x.UserCode == User.FindFirstValue(ClaimTypes.SerialNumber));

                    var decryptedroleCode = _iunitofwork.User.DecrypteBase64(RoleCode);

                    var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == decryptedroleCode);

                    if (requiredRole == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    else if (userRoleInClaim.RoleLevel != RoleLevels.SUPREME && requiredRole.RoleLevel >= userRoleInClaim.RoleLevel)
                        return BadRequest(new { message = ValidationMessages.NoAccess });

                    var isuniqueuser = await _iunitofwork.User.IsUniqueUser(user.MobileNumber);
                    if (!isuniqueuser)
                        return BadRequest(new { message = ValidationMessages.Exists });
                    User adduser = new User()
                    {
                        UserCode = _iunitofwork.User.GenrateUniqueCode(),
                        Name = user.Name,
                        Password = user.Password,
                        MobileNumber = user.MobileNumber,
                        IsMobileVerified = true,
                        IsActive = true,
                        CreatedBy = userInClaim.Name + "/" + userInClaim.UserCode,
                        CreatedOn = DateTime.UtcNow
                    };
                    RoleAccess userrole = new RoleAccess
                    {
                        AccessId = _iunitofwork.RoleAccess.GenrateUniqueCode(),
                        UserCode = adduser.UserCode,
                        RoleCode = requiredRole.RoleCode,
                        AccessToRole = true
                    };

                    await _iunitofwork.User.RegisterUser(adduser);
                    await _iunitofwork.RoleAccess.AddAsync(userrole);
                    return Ok(new { message = ValidationMessages.Created });
                }
                return BadRequest(new { message = ValidationMessages.BadRequest });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPost("authenticate")]
        public async Task<IActionResult> Authenticate([FromBody] AuthenticateVM userVM)
        {
            try
            {
                var userindb = await _iunitofwork.User.FirstOrDefaultAsync(u => u.MobileNumber == userVM.UserName);

                if (userindb == null)
                    return NotFound(new { message = ValidationMessages.UserNotFound });

                else if (userindb.Password != userVM.Password)
                    return BadRequest(new { message = ValidationMessages.WrongPassword });

                else if (userindb.IsActive == false)
                    return BadRequest(new { message = ValidationMessages.InActiveUser });
                else
                {
                    var inDbRoles = (await _iunitofwork.RoleAccess.GetAllAsync(ra => ra.UserCode == userindb.UserCode && ra.AccessToRole == true, includeProperties: "UserRole")).ToList().OrderByDescending(x => x.UserRole.RoleLevel);

                    var userRole = inDbRoles.First(x => x.AccessToRole == true);

                    if (userRole == null)
                        return BadRequest(new { message = ValidationMessages.NoAccess });

                    if(userRole.RoleCode == SD.INDIVIDUAL && userindb.IsMobileVerified == false)
                        return BadRequest(new { message = ValidationMessages.NoAccess });

                    var tokenindb = await _iunitofwork.User.Authenticate(userVM.UserName, userRole.UserRole.RoleCode);

                    await _iunitofwork.User.UpdateAsync(userindb.UserCode, async entity =>
                    {
                        entity.LastLogin = DateTime.UtcNow;
                        await Task.CompletedTask;
                    });

                    return Ok(new { token = tokenindb });
                }
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

        [HttpPost("changeRole")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> ChangeRole(string RoleCode)
        {
            try
            {
                var userCodeInClaim = User.FindFirstValue(ClaimTypes.SerialNumber);
                if (RoleCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedroleCode = _iunitofwork.User.DecrypteBase64(RoleCode);
                var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == decryptedroleCode);

                //finds user in db  by searching its usercode or phone number 
                var userindb = await _iunitofwork.User.FirstOrDefaultAsync(u => u.UserCode == userCodeInClaim);

                if (userindb == null)
                    return NotFound(new { message = ValidationMessages.UserNotFound });

                else
                {
                    var userRole = await _iunitofwork.RoleAccess.FirstOrDefaultAsync(ra => ra.UserCode == userindb.UserCode && ra.AccessToRole == true && ra.RoleCode == requiredRole.RoleCode, includeProperties: "User,UserRole");
                    if (userRole == null)
                        return BadRequest(new { Message = ValidationMessages.NoAccess });

                    var tokenindb = await _iunitofwork.User.Authenticate(userindb.MobileNumber, userRole.UserRole.RoleCode);

                    await _iunitofwork.User.UpdateAsync(userindb.UserCode, async entity =>
                    {
                        entity.LastLogin = DateTime.UtcNow;
                        await Task.CompletedTask;
                    });
                    return Ok(new { token = tokenindb });
                }
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }

        }
    }
}
