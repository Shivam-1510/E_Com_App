using API.Data.IRepository;
using API.Models.Menus;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.UserControllers
{
    [ApiController]
    [Authorize(Policy = SD.IsAccess)]
    [Authorize(Policy = SD.SupremeLevel)]
    [Route("menu")]
    public class MenuController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public MenuController(IUnitOfWork repository)
        {
            _iunitofwork = repository;
        }

        [HttpGet]
        public async Task<IActionResult> GetMenus()
        {
            try
            {
                return Ok(await _iunitofwork.Menu.GetAllAsync());
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("getmenusandsubmenus")]
        public async Task<IActionResult> GetMenusAndSubMenus(string ParantCode)
        {
            try
            {
                var allMenus = (await _iunitofwork.Menu.GetAllAsync(x=>x.Status == true)).ToList();
                if (ParantCode == null)
                {
                    var result = allMenus
                        .Where(menu => menu.ParentCode == null)
                        .Select(mainMenu => _iunitofwork.Menu.GetMenuWithSubmenus(mainMenu, allMenus))
                        .ToList();

                    return Ok(result);
                }
                else
                {
                    var decryptedparantCode = _iunitofwork.Menu.DecrypteBase64(ParantCode);
                    var result = allMenus
                   .Where(menu => menu.ParentCode == decryptedparantCode)
                   .Select(mainMenu => _iunitofwork.Menu.GetMenuWithSubmenus(mainMenu, allMenus))
                   .ToList();
                    return Ok(result);
                }
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("menu")]
        public async Task<IActionResult> GetMenu(string MenuCode)
        {
            try
            {
                if (MenuCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decrypted= _iunitofwork.Menu.DecrypteBase64(MenuCode);
                var indb = await _iunitofwork.Menu.FirstOrDefaultAsync(x => x.MenuCode == decrypted);
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
        public async Task<IActionResult> CreateMenu([FromBody] Menu Menu)
        {
            try
            {
                if (ModelState.IsValid)
                {

                    var indb = await _iunitofwork.Menu.FirstOrDefaultAsync(x => (x.Path == Menu.Path || x.MenuName == Menu.MenuName) && x.ParentCode == Menu.ParentCode);
                    if (indb != null)
                        return BadRequest( new { message = ValidationMessages.Exists });
                    Menu addMenu = new Menu()
                    {
                        MenuCode = _iunitofwork.Menu.GenrateUniqueCode(),
                        MenuName = Menu.MenuName,
                        Path= Menu.Path,
                        Icon = Menu.Icon,
                        ParentCode = Menu.ParentCode,
                        Status = true
                    };
                    await _iunitofwork.Menu.AddAsync(addMenu);
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
        public async Task<IActionResult> UpdateMenu([FromBody] Menu Menu)
        {
            try
            {
                if (ModelState.IsValid)
                {

                    var indb = await _iunitofwork.Menu.FirstOrDefaultAsync(x => x.MenuCode == Menu.MenuCode);
                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });
                    var indbExist = await _iunitofwork.Menu.FirstOrDefaultAsync(x => (x.Path == Menu.Path || x.MenuName == Menu.MenuName) && x.ParentCode == Menu.ParentCode  && x.MenuCode != indb.MenuCode);
                    if (indbExist != null)
                        return BadRequest( new { message = ValidationMessages.Exists });
                    await _iunitofwork.Menu.UpdateAsync(indb.MenuCode, async entity =>
                    {
                        entity.MenuName = Menu.MenuName;
                        entity.Path = Menu.Path;
                        entity.Status = Menu.Status;
                        entity.Icon = Menu.Icon;
                        entity.ParentCode = Menu.ParentCode;
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
        public async Task<IActionResult> DeleteMenu(string MenuCode)
        {
            try
            {
                if (MenuCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedId = _iunitofwork.Menu.DecrypteBase64(MenuCode);
                var indb = await _iunitofwork.Menu.FirstOrDefaultAsync(x => x.MenuCode == decryptedId);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var propshave =await _iunitofwork.Menu.FirstOrDefaultAsync(d => d.ParentCode == indb.MenuCode);
                var roleshave = await _iunitofwork.MenuAccess.FirstOrDefaultAsync(d => d.MenuCode == indb.MenuCode && d.Status == true);

                if (propshave != null || roleshave != null)
                    return BadRequest(new { message = ValidationMessages.ObjectDepends });

                await _iunitofwork.Menu.RemoveAsync(decryptedId);
                return Ok(new { message = ValidationMessages.Deleted });

            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }
    }
}