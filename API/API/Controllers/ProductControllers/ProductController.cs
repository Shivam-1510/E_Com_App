using API.Data.IRepository;
using API.Models.ProductModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace API.Controllers.ProductControllers
{
    [Route("product")]
    [ApiController]
    public class ProductController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        private readonly IImageRepository _imageRepository;
        public ProductController(IUnitOfWork iunitofwork , IImageRepository imageRepository)
        {
            _iunitofwork = iunitofwork;
            _imageRepository = imageRepository;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
               
                var Products = await _iunitofwork.Product.GetAllAsync(includeProperties: "Brand,Category");
                foreach (var Product in Products)
                {
                    Product.FirstImage = _imageRepository.GetImage(Product.FirstImage);
                    Product.SecondImage = _imageRepository.GetImage(Product.SecondImage);
                    Product.ThirdImage = _imageRepository.GetImage(Product.ThirdImage);
                }
                return Ok(Products);
                
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("product")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> GetProduct(string ProductCode)
        {
            try
            {
                if (ProductCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Product.DecrypteBase64(ProductCode);

                var indb = await _iunitofwork.Product.FirstOrDefaultAsync(x => x.ProductCode == decryptedCode, includeProperties: "Brand,Category");

                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });
                else
                {
                    indb.FirstImage = _imageRepository.GetImage(indb.FirstImage);
                    indb.SecondImage = _imageRepository.GetImage(indb.SecondImage);
                    indb.ThirdImage = _imageRepository.GetImage(indb.ThirdImage);

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
        public async Task<IActionResult> Create([FromBody] Product Product)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var userInClaim =  User.FindFirst(ClaimTypes.SerialNumber).Value;

                    var indb = await _iunitofwork.Product.FirstOrDefaultAsync(x => x.ProductName == Product.ProductName && x.BrandCode == Product.BrandCode && x.CategoryCode == Product.CategoryCode );
                    if (indb != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    Product product = new Product()
                    {
                        ProductCode = _iunitofwork.Product.GenrateUniqueCode(),
                        ProductName = Product.ProductName,
                        ProductDescription = Product.ProductDescription,
                        ProductHighLights = Product.ProductHighLights,
                        ProductPrice = Product.ProductPrice,
                        StockCount = Product.StockCount,
                        ProductStatus = false,
                        BrandCode = Product.BrandCode,
                        CategoryCode = Product.CategoryCode,
                        UserCode = userInClaim,
                        FirstImage= _imageRepository.SaveImage( ImageBytes(Product.FirstImage)),
                        SecondImage = _imageRepository.SaveImage(ImageBytes(Product.SecondImage)),
                        ThirdImage = _imageRepository.SaveImage(ImageBytes(Product.ThirdImage)),
                    };
                    await _iunitofwork.Product.AddAsync(product);
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
        public async Task<IActionResult> Update([FromBody] Product Product)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var indb = await _iunitofwork.Product.GetAsync(Product.ProductCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                    var indbExists = await _iunitofwork.Product.FirstOrDefaultAsync(x => x.ProductName == Product.ProductName && x.BrandCode == indb.BrandCode && x.Id != indb.Id);

                    if (indbExists != null)
                        return BadRequest(new { message = ValidationMessages.Exists });

                    await _iunitofwork.Product.UpdateAsync(indb.ProductCode, async entity =>
                    { 
                        entity.ProductName = Product.ProductName;
                        entity.ProductDescription = Product.ProductDescription;
                        entity.ProductHighLights = Product.ProductHighLights;
                        entity.ProductPrice = Product.ProductPrice;
                        entity.ProductStatus = Product.ProductStatus;
                        entity.BrandCode = Product.BrandCode;
                        entity.CategoryCode = Product.CategoryCode;
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

        [HttpPut("productstatus")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> ProductStatus(string ProductCode)
        {
            try
            {
                if (ProductCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Product.DecrypteBase64(ProductCode);

                var indb = await _iunitofwork.Product.GetAsync(decryptedCode);

                    if (indb == null)
                        return NotFound(new { message = ValidationMessages.NotFound });

                  
                    await _iunitofwork.Product.UpdateAsync(indb.ProductCode, async entity =>
                    {
                        entity.ProductStatus = !entity.ProductStatus;
                        await Task.CompletedTask;
                    });
                    return Ok(new { message = ValidationMessages.Updated });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPut("updateimages")]
        [Authorize(Policy = SD.IsAccess)]
        public async Task<IActionResult> UpdateImages([FromBody] ImageModel model)
        {
            try
            {
               
                var indb = await _iunitofwork.Product.GetAsync(model.ProductCode);

                if (indb == null)
                    return NotFound(new { message = ValidationMessages.NotFound });

                await _iunitofwork.Product.UpdateAsync(indb.ProductCode, async entity =>
                {
                    if (model.FirstImageStatus == true)
                        entity.FirstImage = _imageRepository.UpdateImage(entity.FirstImage, ImageBytes(model.FirstImage));
                    if (model.SecondImageStatus == true)
                        entity.SecondImage = _imageRepository.UpdateImage(entity.SecondImage, ImageBytes(model.SecondImage));
                    if(model.ThirdImageStatus == true)
                        entity.ThirdImage = _imageRepository.UpdateImage(entity.ThirdImage, ImageBytes(model.ThirdImage));
                    await Task.CompletedTask;
                });
                return Ok(new { message = ValidationMessages.Updated });
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        private byte[] ImageBytes(string image)
        {
            try
            {
                byte[] byteimage = Convert.FromBase64String(image);
                return byteimage;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

    }
}
