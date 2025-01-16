using API.Data.IRepository;
using API.Models.OrderModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace API.Controllers.OrderControllers
{
    [Route("cart")]
    [ApiController]
    [Authorize(Policy = SD.IsAccess)]

    public class CartController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        private readonly IImageRepository _imageRepository;
        public CartController(IUnitOfWork iunitofwork, IImageRepository imageRepository)
        {
            _iunitofwork = iunitofwork;
            _imageRepository = imageRepository;
        }
        [HttpGet]
        public async Task<IActionResult> GetCartItems(string UserCode)
        {
            try
            {
                if (UserCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedUserCode = _iunitofwork.User.DecrypteBase64(UserCode);


                var items = (await _iunitofwork.Cart.GetAllAsync(x => x.UserCode == decryptedUserCode, includeProperties: "Product.Brand,Product.Category,Size,Color")).ToList();

                foreach (var item in items)
                {
                    item.Product.FirstImage = _imageRepository.GetImage(item.Product.FirstImage);
                    item.Product.SecondImage = _imageRepository.GetImage(item.Product.SecondImage);
                    item.Product.ThirdImage = _imageRepository.GetImage(item.Product.ThirdImage);
                }
                return Ok(items);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpGet("cartitem")]
        public async Task<IActionResult> GetCartItem(string CartCode)
        {
            try
            {
                if (CartCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Cart.DecrypteBase64(CartCode);

                var item = await _iunitofwork.Cart.FirstOrDefaultAsync(x => x.UserCode == decryptedCode, includeProperties: "Product.Brand,Product.Category,Size,Color");
                item.Product.FirstImage = _imageRepository.GetImage(item.Product.FirstImage);
                item.Product.SecondImage = _imageRepository.GetImage(item.Product.SecondImage);
                item.Product.ThirdImage = _imageRepository.GetImage(item.Product.ThirdImage);

                return Ok(item);
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }

        [HttpPost("addcartitem")]
        public async Task<IActionResult> AddCartItem([FromBody] Cart Cart)
        {
            try
            {
                var user = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == User.FindFirst(ClaimTypes.SerialNumber).Value);
             
                var indb = await _iunitofwork.Cart.FirstOrDefaultAsync(x => x.ProductCode == Cart.ProductCode && x.UserCode == user.UserCode && x.ColorCode == Cart.ColorCode && x.SizeCode == Cart.SizeCode);

                if (indb != null)
                {              
                    return BadRequest(new { message = ValidationMessages.Exists });
                }
                else
                {
                    Cart cart = new Cart()
                    {
                        CartCode = _iunitofwork.Cart.GenrateUniqueCode(),
                        UserCode = user.UserCode,
                        Count = Cart.Count,
                        ProductCode = Cart.ProductCode,
                        ColorCode = Cart.ColorCode,
                        SizeCode = Cart.SizeCode,
                        IntiatedAt = DateTime.UtcNow
                    };
                    await _iunitofwork.Cart.AddAsync(cart);
                    return Ok(new { message = ValidationMessages.Created });
                }
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

        [HttpPost("updatecartitem")]
        public async Task<IActionResult> UpdateCartItem([FromBody] Cart Cart)
        {
            try
            {

                var indb = await _iunitofwork.Cart.FirstOrDefaultAsync(x => x.CartCode == Cart.CartCode);

                if (indb != null)
                {
                    await _iunitofwork.Cart.UpdateAsync(indb.CartCode, async entity =>
                    {
                        entity.ColorCode = indb.ColorCode;
                        entity.SizeCode = indb.SizeCode;
                        entity.Count = Cart.Count;
                        entity.IntiatedAt = DateTime.UtcNow;
                        await Task.CompletedTask;
                    });
                    return Ok(new { message = ValidationMessages.Updated });
                }
                else
                {
                    return NotFound(new { message = ValidationMessages.NotFound });
                }
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



        [HttpPut("remove")]
        public async Task<IActionResult> RemoveCartItem(string CartCode)
        {
            try
            {
                if (CartCode == null)
                {
                    return BadRequest(new { message = ValidationMessages.BadRequest });
                }
                var decryptedCode = _iunitofwork.Cart.DecrypteBase64(CartCode);

                var indb = await _iunitofwork.Cart.FirstOrDefaultAsync(x => x.CartCode == decryptedCode);

                if (indb == null)
                {
                    return NotFound(new { message = ValidationMessages.NotFound });
                }
                else
                {
                    await _iunitofwork.Cart.RemoveAsync(indb.CartCode);
                    return Ok(new { message = ValidationMessages.Deleted });
                }
            }
            catch (Exception Ex)
            {
                return StatusCode(500, new { message = ValidationMessages.Default, exception = Ex });
            }
        }


    }
}
