using API.Data.IRepository.ProductRepositories;
using API.Models.ProductModels;

namespace API.Data.Repository.ProductRepositories
{
    public class ProductRepository : Repository<Product>, IProductRepository
    {
        private readonly ApplicationDbContext _context;
        public ProductRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
