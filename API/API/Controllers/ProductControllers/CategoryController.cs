using API.Data.IRepository;
using API.Models.ProductModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.ProductControllers
{
    [Route("category")]
    [ApiController]
    [Authorize(Policy = SD.IsAccess)]

    public class CategoryController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public CategoryController(IUnitOfWork iunitofwork)
        {
            _iunitofwork = iunitofwork;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                return Ok(await _iunitofwork.Category.GetAllAsync());
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("category")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetCategory(string CategoryCode)
        {
            try
            {
                if (CategoryCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Brand.DecrypteBase64(CategoryCode);

                var indb = await _iunitofwork.Category.FirstOrDefaultAsync(x => x.CategoryCode == decryptedCode);

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
        public async Task<IActionResult> Create([FromBody] Category Category)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Category.FirstOrDefaultAsync(x => x.CategoryName == Category.CategoryName);
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    Category category = new Category()
                    {
                        CategoryCode = _iunitofwork.Category.GenrateUniqueCode(),
                        CategoryName = Category.CategoryName,
                    };
                    await _iunitofwork.Category.AddAsync(category);
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
        public async Task<IActionResult> Update([FromBody] Category Category)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Category.GetAsync(Category.CategoryCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    var indbExists = await _iunitofwork.Category.FirstOrDefaultAsync(x => x.CategoryName == Category.CategoryName && x.Id != indb.Id);

                    if (indbExists != null)
                        return BadRequest(new { message = ValidationMessages.Exists });



                    await _iunitofwork.Category.UpdateAsync(indb.CategoryCode, async entity =>
                    {
                        entity.CategoryName = Category.CategoryName;
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
        public async Task<IActionResult> Delete(string CategoryCode)
        {
            try
            {
                if (CategoryCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Category.DecrypteBase64(CategoryCode);
                var indb = await _iunitofwork.Category.GetAsync(decryptedCode);
                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                var productshave = await _iunitofwork.Product.FirstOrDefaultAsync(d => d.CategoryCode == indb.CategoryCode);

                if (productshave != null)
                    return BadRequest(new { message = ValidationMessages.ObjectDepends });

                await _iunitofwork.Category.RemoveAsync(indb.CategoryCode);
                return Ok(new { message = ValidationMessages.Deleted });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

    }
}
