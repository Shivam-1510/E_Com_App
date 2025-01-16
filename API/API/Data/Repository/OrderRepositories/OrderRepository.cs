using API.Data.IRepository.OrderRepositories;
using API.Models.OrderModels;

namespace API.Data.Repository.OrderRepositories
{
    public class OrderRepository : Repository<Order>, IOrderRepository
    {
        private readonly ApplicationDbContext _context;

        public OrderRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
