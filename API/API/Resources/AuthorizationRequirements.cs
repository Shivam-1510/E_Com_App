using Microsoft.AspNetCore.Authorization;

namespace API.Resources
{
    public class IsAccssRequirement : IAuthorizationRequirement { }
    public class SupremeLevelRequirement : IAuthorizationRequirement { }

}
