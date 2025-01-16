using API.Data.IRepository;
using API.Models.ProductModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.ProductControllers
{
    [Route("size")]
    [ApiController]
    public class SizeController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public SizeController(IUnitOfWork iunitofwork)
        {
            _iunitofwork = iunitofwork;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                return Ok(await _iunitofwork.Size.GetAllAsync());
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("size")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetSize(string SizeCode)
        {
            try
            {
                if (SizeCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Size.DecrypteBase64(SizeCode);

                var indb = await _iunitofwork.Size.FirstOrDefaultAsync(x => x.SizeCode == decryptedCode);

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
        public async Task<IActionResult> Create([FromBody] Size Size)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Size.FirstOrDefaultAsync(x => x.SizeName == Size.SizeName);
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    Size size = new Size()
                    {
                        SizeCode = _iunitofwork.Size.GenrateUniqueCode(),
                        SizeName = Size.SizeName,
                        SizeShortName = Size.SizeShortName
                    };
                    await _iunitofwork.Size.AddAsync(size);
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
        public async Task<IActionResult> Update([FromBody] Size Size)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Size.GetAsync(Size.SizeCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    var indbExists = await _iunitofwork.Size.FirstOrDefaultAsync(x => x.SizeName == Size.SizeName && x.Id != indb.Id);

                    if (indbExists != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    await _iunitofwork.Size.UpdateAsync(indb.SizeCode, async entity =>
                    {
                        entity.SizeName = Size.SizeName;
                        entity.SizeShortName = Size.SizeShortName;
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
        public async Task<IActionResult> Delete(string SizeCode)
        {
            try
            {
                if (SizeCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Size.DecrypteBase64(SizeCode);
                var indb = await _iunitofwork.Size.GetAsync(decryptedCode);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var productshave = await _iunitofwork.Stock.FirstOrDefaultAsync(d => d.SizeCode == indb.SizeCode);

                if (productshave != null)
                    return BadRequest(new { message = ValidationMessages.ObjectDepends });

                await _iunitofwork.Size.RemoveAsync(indb.SizeCode);
                return Ok(new { message = ValidationMessages.Deleted });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }
    }
}
