using API.Data.IRepository.OrderRepositories;
using API.Models.OrderModels;

namespace API.Data.Repository.OrderRepositories
{
    public class CartRepository : Repository<Cart>, ICartRepository
    {
        private readonly ApplicationDbContext _context;
        public CartRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
