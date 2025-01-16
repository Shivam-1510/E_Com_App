using API.Data.IRepository;
using API.Models.UserModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace API.Controllers.UserControllers
{
    [Route("management")]
    [ApiController]
    [Authorize(Policy = SD.IsAccess)]
    public class ManagementController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public ManagementController(IUnitOfWork unitofwork)
        {
            _iunitofwork = unitofwork;
        }

        [HttpPut("updateuser")]
        public async Task<IActionResult> UpdateUser([FromBody] User user)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var userInClaim = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == User.FindFirst(ClaimTypes.SerialNumber).Value);
                    var roleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirstValue(ClaimTypes.Role));

                    if (user.UserCode != userInClaim.UserCode)
                    {
                        var indb = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == user.UserCode);
                        if (indb == null)
                            return NotFound(new { message = ValidationMessages.NotFound });

                        var inDbRoles = (await _iunitofwork.RoleAccess.GetAllAsync(ra => ra.UserCode == indb.UserCode, includeProperties: "User,UserRole")).ToList();

                        if (roleInClaim.RoleLevel != RoleLevels.SUPREME && inDbRoles.Any(r => r.UserRole.RoleLevel >= roleInClaim.RoleLevel))
                        {
                            return BadRequest(new { message = ValidationMessages.NoAccess });
                        }
                        await _iunitofwork.User.UpdateAsync(user.UserCode, async entity =>
                        {
                            entity.Name = user.Name;
                            entity.EMail = user.EMail;
                            entity.PanNumber = user.PanNumber;
                            entity.Address = user.Address;
                            entity.PinCode = user.PinCode;
                            entity.UpdatedBy = userInClaim.Name + "/" + userInClaim.UserCode;
                            entity.UpdatedOn = DateTime.UtcNow;
                            await Task.CompletedTask;
                        });
                        return Ok(new { message = ValidationMessages.Updated });
                    }
                    else
                    {
                        await _iunitofwork.User.UpdateAsync(user.UserCode, async entity =>
                        {
                            entity.Name = user.Name;
                            entity.EMail = user.EMail;
                            entity.PanNumber = user.PanNumber;
                            entity.Address = user.Address;
                            entity.PinCode = user.PinCode;
                            entity.UpdatedBy = userInClaim.Name + "/" + userInClaim.UserCode;
                            entity.UpdatedOn = DateTime.UtcNow;
                            await Task.CompletedTask;
                        });

                        return Ok(new { message = ValidationMessages.Updated });
                    }

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
        public async Task<IActionResult> DeleteUser(string UserCode)
        {
            try
            {
                if (UserCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedUserCode = _iunitofwork.User.DecrypteBase64(UserCode);

                var roleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirstValue(ClaimTypes.Role));
                var indb = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == decryptedUserCode);

                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var inDbRoles = (await _iunitofwork.RoleAccess.GetAllAsync(ra => ra.UserCode == indb.UserCode, includeProperties: "User,UserRole")).ToList();

                if (inDbRoles.Any(r => r.UserRole.RoleLevel >= roleInClaim.RoleLevel))
                {
                    return BadRequest(new { message = ValidationMessages.NoAccess });
                }
                await _iunitofwork.User.RemoveAsync(indb);
                return Ok(new { message = ValidationMessages.Deleted });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPut("activedeactiveuser")]
        public async Task<IActionResult> ActiveDeactiveUser(string UserCode)
        {
            try
            {
                if (UserCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedUserCode = _iunitofwork.User.DecrypteBase64(UserCode);

                var roleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirstValue(ClaimTypes.Role));
                var indb = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == decryptedUserCode);

                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var inDbRoles = (await _iunitofwork.RoleAccess.GetAllAsync(ra => ra.UserCode == indb.UserCode, includeProperties: "User,UserRole")).ToList();

                if (inDbRoles.Any(r => r.UserRole.RoleLevel >= roleInClaim.RoleLevel))
                {
                    return BadRequest(new { message = ValidationMessages.NoAccess });
                }
                await _iunitofwork.User.ActiveDeactiveUser(indb.UserCode);

                var updateduser = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == indb.UserCode);
                var userRoles = (await _iunitofwork.RoleAccess.GetAllAsync(ra => ra.UserCode == updateduser.UserCode, includeProperties: "UserRole")).ToList().OrderByDescending(x => x.UserRole.RoleLevel);

                if (updateduser.IsActive == false)
                {
                    foreach (var UserRole in userRoles)
                    {
                        await _iunitofwork.RoleAccess.UpdateAsync(UserRole.AccessId, async entity =>
                        {
                            entity.AccessToRole = false;
                            await Task.CompletedTask;
                        });
                    }
                }
                else if (updateduser.IsActive == true)
                {
                    await _iunitofwork.RoleAccess.UpdateAsync(userRoles.First().AccessId, async entity =>
                    {
                        entity.AccessToRole = true;
                        await Task.CompletedTask;
                    });
                }
                return Ok(new { message = ValidationMessages.Ok });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("useraccessofroles")]
        public async Task<IActionResult> GetUserAccessOfRoles(string UserCode)
        {
            try
            {
                if (UserCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedUserCode = _iunitofwork.User.DecrypteBase64(UserCode);
                var rolesindb = await _iunitofwork.RoleAccess.GetAllAsync(u => u.UserCode == decryptedUserCode && u.AccessToRole == true, includeProperties: "User,UserRole");
                return Ok(rolesindb);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }

        }


        [HttpPost("updateroleaccess")]
        public async Task<IActionResult> UpsertUserAndRoles([FromBody] RoleAccess[] UserAndRoles)
        {
            try
            {
                var userRoleInClaim = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == User.FindFirst(ClaimTypes.Role).Value);

                foreach (var userAndRole in UserAndRoles)
                {
                    var requiredRole = await _iunitofwork.UserRole.FirstOrDefaultAsync(d => d.RoleCode == userAndRole.RoleCode);

                    if (requiredRole.RoleLevel != RoleLevels.SUPREME && requiredRole.RoleLevel >= userRoleInClaim.RoleLevel)
                        return BadRequest(new { message = ValidationMessages.NoAccess });

                    var userAndRoleInDb = await _iunitofwork.RoleAccess.FirstOrDefaultAsync(x => x.RoleCode == userAndRole.RoleCode && x.UserCode == userAndRole.UserCode);
                    if (userAndRoleInDb == null)
                    {
                        RoleAccess addUserAndRole = new RoleAccess()
                        {
                            AccessId = _iunitofwork.RoleAccess.GenrateUniqueCode(),
                            UserCode = userAndRole.UserCode,
                            RoleCode = userAndRole.RoleCode,
                            AccessToRole = true
                        };
                        await _iunitofwork.RoleAccess.AddAsync(addUserAndRole);
                    }
                    else if (userAndRoleInDb.AccessToRole != userAndRole.AccessToRole)
                    {
                        await _iunitofwork.RoleAccess.UpdateAsync(userAndRoleInDb.AccessId, async entity =>
                        {
                            entity.AccessToRole = userAndRole.AccessToRole;
                            await Task.CompletedTask;
                        });
                    }
                }
                return Ok(new { message = ValidationMessages.Ok });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

    }
}
