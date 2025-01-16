using API.Data;
using API.Models.UserModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace API.Resources
{
   
    public class SupremeLevelAuthorizationHandler : AuthorizationHandler<SupremeLevelRequirement>
    {
        private readonly ApplicationDbContext _dbContext;
        public SupremeLevelAuthorizationHandler(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, SupremeLevelRequirement requirement)
        {

            var userRoleInClaim = context.User.FindFirstValue(ClaimTypes.Role);

            var supremeLevelRoles = _dbContext.UserRole.ToList().Where(d => d.RoleLevel == RoleLevels.SUPREME);

            if (userRoleInClaim != null && supremeLevelRoles.Any(role => role.RoleCode == userRoleInClaim))
            {
                context.Succeed(requirement);
            }
            return Task.CompletedTask;

        }
    }

    public class IsAccssAuthorizationHandler : AuthorizationHandler<IsAccssRequirement>
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public IsAccssAuthorizationHandler(ApplicationDbContext dbContext, IHttpContextAccessor httpContextAccessor)
        {
            _dbContext = dbContext;
            _httpContextAccessor = httpContextAccessor;
        }

        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, IsAccssRequirement requirement)
        {
            var CurrentRoute = _httpContextAccessor.HttpContext.Request.Path;
            var userRoleInClaim = context.User.FindFirstValue(ClaimTypes.Role);
            var userCodeInClaim = context.User.FindFirstValue(ClaimTypes.SerialNumber);
            if(CurrentRoute== null || userCodeInClaim == null || userCodeInClaim == null)
            {
                return Task.CompletedTask;
            }

            var userRoleInDb = _dbContext.UserRole.FirstOrDefault(r => r.RoleCode == userRoleInClaim);

            var userAccessInDb = _dbContext.RoleAccess.FirstOrDefault(x => x.RoleCode == userRoleInDb.RoleCode && x.UserCode == userCodeInClaim);

            var RoleAccessInDb = _dbContext.RouteAccess.Include(r => r.Route).ToList().Where(d => d.Route.Path == CurrentRoute && d.RoleCode == userRoleInClaim);

            if (userRoleInDb != null && userAccessInDb != null && userRoleInDb.RoleLevel == RoleLevels.SUPREME && userAccessInDb.AccessToRole == true)
            {
                context.Succeed(requirement);
            }
            else if (userRoleInDb != null && userAccessInDb != null && RoleAccessInDb !=null && userAccessInDb.AccessToRole == true && RoleAccessInDb.Any(x => x.Status == true))
            {
                context.Succeed(requirement);
            }
            return Task.CompletedTask;
        }
    }


}
