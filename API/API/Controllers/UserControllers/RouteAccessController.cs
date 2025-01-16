using API.Data.IRepository;
using API.Models.Routes;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Route = API.Models.Routes.Route;

namespace API.Controllers.UserControllers
{
    [ApiController]
    [Route("routeaccess")]
    [Authorize(Policy = SD.IsAccess)]
    [Authorize(Policy = SD.SupremeLevel)]
    public class RouteAccessController : ControllerBase
    {
        private readonly IUnitOfWork _iunitofwork;
        public RouteAccessController(IUnitOfWork repository)
        {
            _iunitofwork = repository;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllRouteAccess()
        {
            try
            {
                var list = await _iunitofwork.RouteAccess.GetAllAsync(includeProperties: "UserRole,Route");
                return Ok(list);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }
       
        [HttpGet("getaccessedroutes")]
        public async Task<IActionResult> GetAccessedRoutesWithRole(string RoleCode)
        {
            try
            {
                var decryptedRoleCode = _iunitofwork.UserRole.DecrypteBase64(RoleCode);
                var allMappedRoutes = await _iunitofwork.RouteAccess.GetAllAsync(d => d.RoleCode == decryptedRoleCode && d.Status == true && d.Route.Status == true, includeProperties: "UserRole,Route");

                List<Route> allRoutes = new List<Route>();

                foreach (var mappedRoute in allMappedRoutes)
                {
                    var Route = mappedRoute.Route;
                    allRoutes.Add(Route);
                }
                var RoutesAndSubRoutes = allRoutes
                    .Where(Route => Route.ParentCode == null)
                    .Select(mainRoute => _iunitofwork.Route.GetRouteWithSubRoutes(mainRoute, allRoutes))
                    .ToList();
                return Ok(RoutesAndSubRoutes);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPost("createandupdate")]
        public async Task<IActionResult> CreateAndUpdateRouteAccess([FromBody] RouteAccess[] routeAccesses)
        {
            try
            {
                foreach (var routeAccess in routeAccesses)
                {
                    var InDb = await _iunitofwork.RouteAccess.FirstOrDefaultAsync(x => x.RouteCode == routeAccess.RouteCode && x.RoleCode == routeAccess.RoleCode);

                    if (InDb == null)
                    {
                        RouteAccess mapping = new RouteAccess()
                        {
                            AccessCode = _iunitofwork.RouteAccess.GenrateUniqueCode(),
                            RouteCode = routeAccess.RouteCode,
                            RoleCode = routeAccess.RoleCode,
                            Status = true
                        };
                        await _iunitofwork.RouteAccess.AddAsync(mapping);
                    }
                    else if (InDb.Status != routeAccess.Status)
                    {
                        await _iunitofwork.RouteAccess.UpdateAsync(InDb.AccessCode, async entity =>
                        {
                            entity.Status = routeAccess.Status;
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
