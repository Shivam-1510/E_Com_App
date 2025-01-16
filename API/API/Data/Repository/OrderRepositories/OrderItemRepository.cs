using API.Data.IRepository.OrderRepositories;
using API.Models.OrderModels;

namespace API.Data.Repository.OrderRepositories
{
    public class OrderItemRepository : Repository<OrderItem>, IOrderItemRepository
    {
        private readonly ApplicationDbContext _context;
        public OrderItemRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
