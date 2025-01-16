using API.Data.IRepository;
using API.Models.ProductModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.ProductControllers
{
    [Route("brand")]
    [ApiController]
    public class BrandController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public BrandController(IUnitOfWork iunitofwork)
        {
            _iunitofwork = iunitofwork;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                return Ok(await _iunitofwork.Brand.GetAllAsync());
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("brand")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetBrand(string BrandCode)
        {
            try
            {
                if (BrandCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Brand.DecrypteBase64(BrandCode);

                var indb = await _iunitofwork.Brand.FirstOrDefaultAsync(x=>x.BrandCode== decryptedCode);

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
        public async Task<IActionResult> Create([FromBody] Brand Brand)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Brand.FirstOrDefaultAsync(x=>x.BrandName == Brand.BrandName);
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    Brand brand = new Brand()
                    {
                        BrandCode = _iunitofwork.Brand.GenrateUniqueCode(),
                        BrandName = Brand.BrandName,
                        BrandDetails = Brand.BrandDetails
                    };
                    await _iunitofwork.Brand.AddAsync(brand);
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
        public async Task<IActionResult> Update([FromBody] Brand Brand)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Brand.GetAsync(Brand.BrandCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    var indbExists = await _iunitofwork.Brand.FirstOrDefaultAsync(x => x.BrandName == Brand.BrandName && x.Id != indb.Id);
                   
                    if (indbExists != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

               

                    await _iunitofwork.Brand.UpdateAsync(indb.BrandCode, async entity =>
                    {
                        entity.BrandName = Brand.BrandName;
                        entity.BrandDetails = Brand.BrandDetails;
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
        public async Task<IActionResult> Delete(string BrandCode)
        {
            try
            {
                if (BrandCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Brand.DecrypteBase64(BrandCode);
                var indb = await _iunitofwork.Brand.GetAsync(decryptedCode);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var productshave = await _iunitofwork.Product.FirstOrDefaultAsync(d => d.BrandCode == indb.BrandCode);
               
                if (productshave != null )
                    return BadRequest(new { message = ValidationMessages.ObjectDepends });

                await _iunitofwork.Brand.RemoveAsync(indb.BrandCode);
                return Ok(new { message = ValidationMessages.Deleted });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

    }
}
