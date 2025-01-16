using API.Data.IRepository;
using API.Models.Menus;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Route = API.Models.Routes.Route;


namespace API.Controllers.UserControllers
{
    [ApiController]
    [Authorize(Policy = SD.IsAccess)]
    [Authorize(Policy = SD.SupremeLevel)]
    [Route("route")]
    public class RouteController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public RouteController(IUnitOfWork repository)
        {
            _iunitofwork = repository;
        }

        [HttpGet]
        public async Task<IActionResult> GetRoutes()
        {
            try
            {
                return Ok(await _iunitofwork.Route.GetAllAsync());
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }
        [HttpGet("getroutesandsubroutes")]
        public async Task<IActionResult> GetRoutesAndSubRoutes(string ParantCode)
        {
            try
            {
                var allRoutes = (await _iunitofwork.Route.GetAllAsync(x => x.Status == true)).ToList();
                if (ParantCode == null)
                {
                    var result = allRoutes
                        .Where(Route => Route.ParentCode == null)
                        .Select(mainRoute => _iunitofwork.Route.GetRouteWithSubRoutes(mainRoute, allRoutes))
                        .ToList();

                    return Ok(result);
                }
                else
                {
                    var decryptedparantCode = _iunitofwork.Route.DecrypteBase64(ParantCode);
                    var result = allRoutes
                       .Where(Route => Route.ParentCode == decryptedparantCode)
                       .Select(mainRoute => _iunitofwork.Route.GetRouteWithSubRoutes(mainRoute, allRoutes))
                       .ToList();
                    return Ok(result);
                }
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("route")]
        public async Task<IActionResult> GetRoute(string RouteCode)
        {
            try
            {
                if (RouteCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decrypted = _iunitofwork.Route.DecrypteBase64(RouteCode);
                var indb = await _iunitofwork.Route.FirstOrDefaultAsync(x => x.RouteCode == decrypted);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });
                return Ok(indb);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> CreateRoute([FromBody] Route Route)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Route.FirstOrDefaultAsync(x => (x.Path == Route.Path || x.RouteName == Route.RouteName) && x.ParentCode == Route.ParentCode);
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });
                    Route addRoute = new Route()
                    {
                        RouteCode = _iunitofwork.Route.GenrateUniqueCode(),
                        RouteName = Route.RouteName,
                        Path = Route.Path,
                        ParentCode = Route.ParentCode,
                        Status = true
                    };
                    await _iunitofwork.Route.AddAsync(addRoute);
                    return Ok(new { message = ValidationMessages.Created });
                }
                else
                    return BadRequest(new { message = ValidationMessages.BadRequest });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPut("update")]
        public async Task<IActionResult> UpdateRoute([FromBody] Route Route)
        {
            try
            {
                if (ModelState.IsValid)
                {

                    var indb = await _iunitofwork.Route.FirstOrDefaultAsync(x => x.RouteCode == Route.RouteCode);
                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });
                    var indbExist = await _iunitofwork.Route.FirstOrDefaultAsync(x => (x.Path == Route.Path || x.RouteName == Route.RouteName) && x.RouteCode != indb.RouteCode);
                    if (indbExist != null)
                        return BadRequest(new { message = ValidationMessages.Exists });
                    await _iunitofwork.Route.UpdateAsync(indb.RouteCode, async entity =>
                    {
                        entity.RouteName = Route.RouteName;
                        entity.Path = Route.Path;
                        entity.Status = Route.Status;
                        entity.ParentCode = Route.ParentCode;
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
        public async Task<IActionResult> DeleteRoute(string RouteCode)
        {
            try
            {
                if (RouteCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decrypted = _iunitofwork.Route.DecrypteBase64(RouteCode);
                var indb = await _iunitofwork.Route.FirstOrDefaultAsync(x => x.RouteCode == decrypted);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var propshave = await _iunitofwork.RouteAccess.FirstOrDefaultAsync(d => d.RouteCode == indb.RouteCode);
                if (propshave != null)
                    return BadRequest(new { message = ValidationMessages.ObjectDepends });

                await _iunitofwork.Route.RemoveAsync(decrypted);
                return Ok(new { message = ValidationMessages.Deleted });

            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }
    }
}
