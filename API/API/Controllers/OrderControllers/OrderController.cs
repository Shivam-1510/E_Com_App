using API.Data.IRepository;
using API.Models.OrderModels;
using API.Models.PaymentModels;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace API.Controllers.OrderControllers
{
    [Route("order")]
    [ApiController]
    [Authorize]
    public class OrderController : Controller
    {
        private readonly IUnitOfWork _iunitofwork;
        public OrderController(IUnitOfWork iunitofwork)
        {
            _iunitofwork = iunitofwork;
        }

        [HttpPut("order")]
        public async Task<IActionResult> GetOrder(string OrderCode)
        {
            try
            {

                var decryptedCode = _iunitofwork.Order.DecrypteBase64(OrderCode);
                var item = await _iunitofwork.Order.FirstOrDefaultAsync(x => x.OrderCode == decryptedCode);
                if (item == null)
                {
                    return NotFound(new { message = ValidationMessages.NotFound });
                }
                else
                {
                    var orderItems = await _iunitofwork.OrderItem.GetAllAsync(x=>x.OrderCode == item.OrderCode, includeProperties: "Order.User,Product.Category,Product.brand,Size,Color");
                    OrderVM orderVM = new OrderVM()
                    {
                        Order = item,
                        OrderItems = orderItems.ToList()
                    };
                    return Ok(orderVM);
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

        [HttpPut("getorders")]
        public async Task<IActionResult> GetOrders()
        {
            try
            {
                List<OrderVM> ordersList = new List<OrderVM>();
                var orders = await _iunitofwork.Order.GetAllAsync();

                foreach (var order in orders) 
                {
                    var orderItems = await _iunitofwork.OrderItem.GetAllAsync(x => x.OrderCode == order.OrderCode, includeProperties: "Order.User,Product.Category,Product.brand,Size,Color");

                    OrderVM orderVM = new OrderVM()
                    {
                        Order = order,
                        OrderItems=orderItems.ToList()
                    };
                    ordersList.Add(orderVM);
                }
                return Ok(ordersList);        
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


        [HttpPost("addorder")]
        public async Task<IActionResult> AddOrder([FromBody] AddOrderVM AddOrderVM)
        {
            try
            {
                if (AddOrderVM.PaymentMethod !=PaymentMethod.COD)
                {
                 //payment gateway flow
                }

                var user = await _iunitofwork.User.FirstOrDefaultAsync(d => d.UserCode == User.FindFirst(ClaimTypes.SerialNumber).Value);


                Order order = new Order()
                {
                    OrderCode = _iunitofwork.Order.GenrateUniqueCode(),
                    UserCode = user.UserCode,
                    OrderStatus = OrderStatus.Pending
                };
                await _iunitofwork.Order.AddAsync(order);
                double orderAmount = 0;
                int orderItemCount = 0;
                foreach (var orderItem in AddOrderVM.OrderItems)
                {
                    var productInDb = await _iunitofwork.Product.FirstOrDefaultAsync(x => x.ProductCode == orderItem.ProductCode);

                    OrderItem item = new OrderItem()
                    {
                        OrderItemCode = _iunitofwork.OrderItem.GenrateUniqueCode(),
                        OrderCode = order.OrderCode,
                        ProductCode = orderItem.ProductCode,
                        ColorCode = orderItem.ColorCode,
                        SizeCode = orderItem.SizeCode,
                        Count = orderItem.Count
                    };
                    await _iunitofwork.OrderItem.AddAsync(item);
                    await _iunitofwork.Cart.RemoveAsync(orderItem.CartCode);
                    var itemStockInDb = await _iunitofwork.Stock.FirstOrDefaultAsync(x => x.ProductCode == item.ProductCode && x.ColorCode == item.ColorCode && x.SizeCode == item.SizeCode);
                    if(itemStockInDb.StockCount == 0)
                    {
                        return BadRequest(new { message = ValidationMessages.NoContent });
                    }
                    await _iunitofwork.Stock.UpdateAsync(itemStockInDb.StockCode, async entity =>
                    {
                        entity.StockCount = entity.StockCount = item.Count;
                        await Task.CompletedTask;
                    });

                    orderAmount += (productInDb.ProductPrice * item.Count );
                    orderItemCount += 1;
                }
                
                if (AddOrderVM.PaymentMethod == PaymentMethod.COD)
                {
                    await _iunitofwork.Order.UpdateAsync(order.OrderCode, async entity =>
                    {
                        entity.PaymentStatus = PaymentStatus.COD;
                        entity.TransactionID = _iunitofwork.Order.GenrateUniqueCode();
                        entity.PaymentBy = user.Name;
                        await Task.CompletedTask;
                    });
                }
                await _iunitofwork.Order.UpdateAsync(order.OrderCode, async entity =>
                {
                    entity.OrderAmount = orderAmount;
                    entity.ItemCount = orderItemCount;
                    entity.OrderStatus = OrderStatus.Initiated;
                    entity.OrderDate = DateTime.Now;
                    await Task.CompletedTask;
                });

                return Ok(new { message = ValidationMessages.Ok });
                
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

        [HttpPut("shiporder")]
        public async Task<IActionResult> ShipOrder(string OrderCode)
        {
            try
            {

                var decryptedCode = _iunitofwork.Order.DecrypteBase64(OrderCode);
                var item = await _iunitofwork.Order.FirstOrDefaultAsync(x => x.OrderCode == decryptedCode);
                await _iunitofwork.Order.UpdateAsync(item.OrderCode, async entity =>
                {
                    entity.OrderStatus = OrderStatus.Shipped;
                    await Task.CompletedTask;
                });
                return Ok(new { message = ValidationMessages.Ok });
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

    }
}
