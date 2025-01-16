using API.Data.IRepository;
using API.Models.ProductModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.ProductControllers
{
    [Route("stock")]
    [ApiController]
    public class StockController : ControllerBase
    {
        private readonly IUnitOfWork _iunitofwork;
        public StockController(IUnitOfWork iunitofwork)
        {
            _iunitofwork = iunitofwork;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(string ProductCode)
        {
            try
            {
                if (ProductCode == null)
                {
                    return Ok(await _iunitofwork.Stock.GetAllAsync(includeProperties: "Product.Brand,Product.Category,Size,Color"));
                }
                else
                {
                    var decryptedCode = _iunitofwork.Product.DecrypteBase64(ProductCode);
                    return Ok(await _iunitofwork.Stock.GetAllAsync(x=>x.ProductCode == decryptedCode,includeProperties: "Product.Brand,Product.Category,Size,Color"));
                }
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("stock")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetStock(string StockCode)
        {
            try
            {
                if (StockCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                else
                {
                    var decryptedCode = _iunitofwork.Stock.DecrypteBase64(StockCode);

                    var indb = await _iunitofwork.Stock.FirstOrDefaultAsync(x => x.StockCode == decryptedCode, includeProperties: "Product.Brand,Product.Category,Size,Color");

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    return Ok(indb);
                }
                
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }


        [HttpPost("create")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> Create([FromBody] Stock Stock)
        {
            try
            {
                if (ModelState.IsValid)
                {

                    var indb = await _iunitofwork.Stock.FirstOrDefaultAsync(x => x.ProductCode == Stock.ProductCode && x.SizeCode == Stock.SizeCode && x.ColorCode == Stock.ColorCode);
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    Stock productStock = new Stock()
                    {
                        StockCode = _iunitofwork.Stock.GenrateUniqueCode(),
                        SizeCode = Stock.SizeCode,
                        ColorCode = Stock.ColorCode,
                        StockCount = Stock.StockCount
                     };
                    await _iunitofwork.Stock.AddAsync(productStock);
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
        public async Task<IActionResult> Update(string StockCode, string StockCount)
        {
            try
            {
                var decryptedCode = _iunitofwork.Stock.DecrypteBase64(StockCode);
                var decryptedCount = int.Parse(_iunitofwork.Stock.DecrypteBase64(StockCount));

                var indb = await _iunitofwork.Stock.GetAsync(decryptedCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                  
                    await _iunitofwork.Stock.UpdateAsync(indb.StockCode, async entity =>
                    {
                        entity.StockCount = decryptedCount;
                        await Task.CompletedTask;
                    });
                    return Ok(new { message = ValidationMessages.Updated });
               
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

    }
}
