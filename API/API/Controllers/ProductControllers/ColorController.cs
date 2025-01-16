using API.Data.IRepository;
using API.Models.ProductModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.ProductControllers
{
    [Route("color")]
    [ApiController]
    public class ColorController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public ColorController(IUnitOfWork iunitofwork)
        {
            _iunitofwork = iunitofwork;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                return Ok(await _iunitofwork.Color.GetAllAsync());
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("color")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetColor(string ColorCode)
        {
            try
            {
                if (ColorCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Color.DecrypteBase64(ColorCode);

                var indb = await _iunitofwork.Color.FirstOrDefaultAsync(x => x.ColorCode == decryptedCode);

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
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> Create([FromBody] Color Color)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Color.FirstOrDefaultAsync(x => x.ColorName == Color.ColorName);
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    Color color = new Color()
                    {
                        ColorCode = _iunitofwork.Color.GenrateUniqueCode(),
                        ColorName = Color.ColorName
                    };
                    await _iunitofwork.Color.AddAsync(color);
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
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> Update([FromBody] Color Color)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Color.GetAsync(Color.ColorCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    var indbExists = await _iunitofwork.Color.FirstOrDefaultAsync(x => x.ColorName == Color.ColorName && x.Id != indb.Id);

                    if (indbExists != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    await _iunitofwork.Color.UpdateAsync(indb.ColorCode, async entity =>
                    {
                        entity.ColorName = Color.ColorName;
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
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> Delete(string ColorCode)
        {
            try
            {
                if (ColorCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Color.DecrypteBase64(ColorCode);
                var indb = await _iunitofwork.Color.GetAsync(decryptedCode);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var productshave = await _iunitofwork.Stock.FirstOrDefaultAsync(d => d.ColorCode == indb.ColorCode);

                if (productshave != null)
                    return BadRequest(new { message = ValidationMessages.ObjectDepends });

                await _iunitofwork.Color.RemoveAsync(indb.ColorCode);

                return Ok(new { message = ValidationMessages.Deleted });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }
    }
}
