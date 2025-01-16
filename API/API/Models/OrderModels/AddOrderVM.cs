using API.Models.PaymentModels;

namespace API.Models.OrderModels
{
    public class AddOrderVM
    {
        public List<Cart> OrderItems { get; set; }

        public PaymentMethod PaymentMethod { get; set; }
    }
}
