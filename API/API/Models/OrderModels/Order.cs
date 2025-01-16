using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using API.Models.UserModels;
using API.Models.PaymentModels;

namespace API.Models.OrderModels
{
    public class Order
    {

        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string OrderCode { get; set; }

        [Required]
        public string UserCode { get; set; }
        public User User { get; set; }

        public DateTime OrderDate { get; set; }

        public int ItemCount { get; set; }

        public double OrderAmount { get; set; }

        public double ShippingFee { get; set; }

        public string TrackingNumber { get; set; }

        public DateTime ShippingDate  { get; set; }

        public DateTime DeliveryDate { get; set; }

        public OrderStatus OrderStatus { get; set; }

        public PaymentMethod PaymentMethod { get; set; }

        public string PaymentBy { get; set; }

        public string TransactionID { get; set; }

        public DateTime PaymentDate { get; set; }

        public double Amount { get; set; }

        public PaymentStatus PaymentStatus { get; set; }

    }
}
