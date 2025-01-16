using API.Data.IRepository.ProductRepositories;
using API.Models.ProductModels;

namespace API.Data.Repository.ProductRepositories
{
    public class StockRepository : Repository<Stock>, IStockRepository
    {
        private readonly ApplicationDbContext _context;

        public StockRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
