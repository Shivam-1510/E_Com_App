using API.Data.IRepository;
using API.Models.Menus;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.UserControllers
{
    [ApiController]
    [Route("menuaccess")]
    [Authorize(Policy = SD.IsAccess)]
    public class MenuAccessController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public MenuAccessController(IUnitOfWork repository)
        {
            _iunitofwork = repository;
        }

        [HttpGet]
        [Authorize(Policy = SD.SupremeLevel)]
        public async Task<IActionResult> GetAllMappingMenus()
        {
            try
            {
                var list = await _iunitofwork.MenuAccess.GetAllAsync(includeProperties: "UserRole,Menu");
                return Ok(list);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("getAccessedMenus")]
        public async Task<IActionResult> GetAccessedMenusWithRole(string RoleCode)
        {
            try
            {
                var decryptedRoleCode = _iunitofwork.UserRole.DecrypteBase64(RoleCode);
                var allMappedMenus = await _iunitofwork.MenuAccess.GetAllAsync(d => d.RoleCode == decryptedRoleCode && d.Status == true && d.Menu.Status == true, includeProperties: "UserRole,Menu");

                List<Menu> allMenus = new List<Menu>();

                foreach (var mappedMenu in allMappedMenus)
                {
                    var menu = mappedMenu.Menu;
                    allMenus.Add(menu);
                }
                var menusAndSubMenus = allMenus
                    .Where(menu => menu.ParentCode == null)
                    .Select(mainMenu => _iunitofwork.Menu.GetMenuWithSubmenus(mainMenu, allMenus))
                    .ToList();
                return Ok(menusAndSubMenus);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPost("createandupdate")]
        [Authorize(Policy = SD.SupremeLevel)]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> CreateAndUpdateMappingMenus([FromBody] MenuAccess[] mappingMenus)
        {
            try
            {
                foreach (var menu in mappingMenus)
                {
                    var menuInDb = await _iunitofwork.MenuAccess.FirstOrDefaultAsync(x => x.MenuCode == menu.MenuCode && x.RoleCode == menu.RoleCode);

                    if (menuInDb == null)
                    {
                        MenuAccess mapping = new MenuAccess()
                        {
                            AccessCode = _iunitofwork.MenuAccess.GenrateUniqueCode(),
                            MenuCode = menu.MenuCode,
                            RoleCode = menu.RoleCode,
                            Status = true
                        };
                        await _iunitofwork.MenuAccess.AddAsync(mapping);
                    }
                    else if (menuInDb.Status != menu.Status)
                    {
                        await _iunitofwork.MenuAccess.UpdateAsync(menuInDb.AccessCode, async entity =>
                        {
                            entity.Status = menu.Status;
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


