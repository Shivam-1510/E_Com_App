namespace API.Models.OrderModels
{
    public class OrderVM
    {
        public Order Order { get; set; }

        public List<OrderItem> OrderItems { get; set; }
    }
}
