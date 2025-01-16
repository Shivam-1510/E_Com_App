using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace API.Migrations
{
    /// <inheritdoc />
    public partial class InitLoad : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Brand",
                columns: table => new
                {
                    BrandCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    BrandName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    BrandDetails = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Brand", x => x.BrandCode);
                });

            migrationBuilder.CreateTable(
                name: "Category",
                columns: table => new
                {
                    CategoryCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CategoryName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Category", x => x.CategoryCode);
                });

            migrationBuilder.CreateTable(
                name: "Color",
                columns: table => new
                {
                    ColorCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ColorName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Color", x => x.ColorCode);
                });

            migrationBuilder.CreateTable(
                name: "Menu",
                columns: table => new
                {
                    MenuCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MenuName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Path = table.Column<string>(type: "text", nullable: false),
                    Icon = table.Column<string>(type: "text", nullable: true),
                    Status = table.Column<bool>(type: "boolean", nullable: false),
                    ParentCode = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Menu", x => x.MenuCode);
                });

            migrationBuilder.CreateTable(
                name: "Route",
                columns: table => new
                {
                    RouteCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    RouteName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Path = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<bool>(type: "boolean", nullable: false),
                    ParentCode = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Route", x => x.RouteCode);
                });

            migrationBuilder.CreateTable(
                name: "Size",
                columns: table => new
                {
                    SizeCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SizeName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    SizeShortName = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Size", x => x.SizeCode);
                });

            migrationBuilder.CreateTable(
                name: "User",
                columns: table => new
                {
                    UserCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Password = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    MobileNumber = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    IsMobileVerified = table.Column<bool>(type: "boolean", nullable: false),
                    EMail = table.Column<string>(type: "text", nullable: true),
                    PanNumber = table.Column<string>(type: "text", nullable: true),
                    Address = table.Column<string>(type: "text", nullable: true),
                    PinCode = table.Column<string>(type: "text", nullable: true),
                    Token = table.Column<string>(type: "text", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<string>(type: "text", nullable: true),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedBy = table.Column<string>(type: "text", nullable: true),
                    LastLogin = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_User", x => x.UserCode);
                });

            migrationBuilder.CreateTable(
                name: "UserRole",
                columns: table => new
                {
                    RoleCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    RoleName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    RoleLevel = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRole", x => x.RoleCode);
                });

            migrationBuilder.CreateTable(
                name: "Order",
                columns: table => new
                {
                    OrderCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserCode = table.Column<string>(type: "text", nullable: false),
                    OrderDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ItemCount = table.Column<int>(type: "integer", nullable: false),
                    OrderAmount = table.Column<double>(type: "double precision", nullable: false),
                    ShippingFee = table.Column<double>(type: "double precision", nullable: false),
                    TrackingNumber = table.Column<string>(type: "text", nullable: true),
                    ShippingDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    DeliveryDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    OrderStatus = table.Column<int>(type: "integer", nullable: false),
                    PaymentMethod = table.Column<int>(type: "integer", nullable: false),
                    PaymentBy = table.Column<string>(type: "text", nullable: true),
                    TransactionID = table.Column<string>(type: "text", nullable: true),
                    PaymentDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Amount = table.Column<double>(type: "double precision", nullable: false),
                    PaymentStatus = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Order", x => x.OrderCode);
                    table.ForeignKey(
                        name: "FK_Order_User_UserCode",
                        column: x => x.UserCode,
                        principalTable: "User",
                        principalColumn: "UserCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Product",
                columns: table => new
                {
                    ProductCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ProductName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    ProductHighLights = table.Column<string>(type: "text", nullable: true),
                    ProductDescription = table.Column<string>(type: "text", nullable: false),
                    CategoryCode = table.Column<string>(type: "text", nullable: false),
                    BrandCode = table.Column<string>(type: "text", nullable: false),
                    ProductPrice = table.Column<double>(type: "double precision", nullable: false),
                    FirstImage = table.Column<string>(type: "text", nullable: false),
                    SecondImage = table.Column<string>(type: "text", nullable: false),
                    ThirdImage = table.Column<string>(type: "text", nullable: false),
                    StockCount = table.Column<int>(type: "integer", nullable: false),
                    UserCode = table.Column<string>(type: "text", nullable: false),
                    ProductStatus = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Product", x => x.ProductCode);
                    table.ForeignKey(
                        name: "FK_Product_Brand_BrandCode",
                        column: x => x.BrandCode,
                        principalTable: "Brand",
                        principalColumn: "BrandCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Product_Category_CategoryCode",
                        column: x => x.CategoryCode,
                        principalTable: "Category",
                        principalColumn: "CategoryCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Product_User_UserCode",
                        column: x => x.UserCode,
                        principalTable: "User",
                        principalColumn: "UserCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MenuAccess",
                columns: table => new
                {
                    AccessCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MenuCode = table.Column<string>(type: "text", nullable: false),
                    RoleCode = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MenuAccess", x => x.AccessCode);
                    table.ForeignKey(
                        name: "FK_MenuAccess_Menu_MenuCode",
                        column: x => x.MenuCode,
                        principalTable: "Menu",
                        principalColumn: "MenuCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MenuAccess_UserRole_RoleCode",
                        column: x => x.RoleCode,
                        principalTable: "UserRole",
                        principalColumn: "RoleCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RoleAccess",
                columns: table => new
                {
                    AccessId = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserCode = table.Column<string>(type: "text", nullable: false),
                    RoleCode = table.Column<string>(type: "text", nullable: false),
                    AccessToRole = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RoleAccess", x => x.AccessId);
                    table.ForeignKey(
                        name: "FK_RoleAccess_UserRole_RoleCode",
                        column: x => x.RoleCode,
                        principalTable: "UserRole",
                        principalColumn: "RoleCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RoleAccess_User_UserCode",
                        column: x => x.UserCode,
                        principalTable: "User",
                        principalColumn: "UserCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RouteAccess",
                columns: table => new
                {
                    AccessCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    RouteCode = table.Column<string>(type: "text", nullable: false),
                    RoleCode = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RouteAccess", x => x.AccessCode);
                    table.ForeignKey(
                        name: "FK_RouteAccess_Route_RouteCode",
                        column: x => x.RouteCode,
                        principalTable: "Route",
                        principalColumn: "RouteCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RouteAccess_UserRole_RoleCode",
                        column: x => x.RoleCode,
                        principalTable: "UserRole",
                        principalColumn: "RoleCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Cart",
                columns: table => new
                {
                    CartCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ProductCode = table.Column<string>(type: "text", nullable: false),
                    SizeCode = table.Column<string>(type: "text", nullable: false),
                    ColorCode = table.Column<string>(type: "text", nullable: false),
                    UserCode = table.Column<string>(type: "text", nullable: false),
                    Count = table.Column<int>(type: "integer", nullable: false),
                    IntiatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cart", x => x.CartCode);
                    table.ForeignKey(
                        name: "FK_Cart_Color_ColorCode",
                        column: x => x.ColorCode,
                        principalTable: "Color",
                        principalColumn: "ColorCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Cart_Product_ProductCode",
                        column: x => x.ProductCode,
                        principalTable: "Product",
                        principalColumn: "ProductCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Cart_Size_SizeCode",
                        column: x => x.SizeCode,
                        principalTable: "Size",
                        principalColumn: "SizeCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Cart_User_UserCode",
                        column: x => x.UserCode,
                        principalTable: "User",
                        principalColumn: "UserCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrderItem",
                columns: table => new
                {
                    OrderItemCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    OrderCode = table.Column<string>(type: "text", nullable: false),
                    ProductCode = table.Column<string>(type: "text", nullable: false),
                    SizeCode = table.Column<string>(type: "text", nullable: false),
                    ColorCode = table.Column<string>(type: "text", nullable: false),
                    Count = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderItem", x => x.OrderItemCode);
                    table.ForeignKey(
                        name: "FK_OrderItem_Color_ColorCode",
                        column: x => x.ColorCode,
                        principalTable: "Color",
                        principalColumn: "ColorCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderItem_Order_OrderCode",
                        column: x => x.OrderCode,
                        principalTable: "Order",
                        principalColumn: "OrderCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderItem_Product_ProductCode",
                        column: x => x.ProductCode,
                        principalTable: "Product",
                        principalColumn: "ProductCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderItem_Size_SizeCode",
                        column: x => x.SizeCode,
                        principalTable: "Size",
                        principalColumn: "SizeCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Stock",
                columns: table => new
                {
                    StockCode = table.Column<string>(type: "text", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ProductCode = table.Column<string>(type: "text", nullable: false),
                    SizeCode = table.Column<string>(type: "text", nullable: false),
                    ColorCode = table.Column<string>(type: "text", nullable: false),
                    StockCount = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stock", x => x.StockCode);
                    table.ForeignKey(
                        name: "FK_Stock_Color_ColorCode",
                        column: x => x.ColorCode,
                        principalTable: "Color",
                        principalColumn: "ColorCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Stock_Product_ProductCode",
                        column: x => x.ProductCode,
                        principalTable: "Product",
                        principalColumn: "ProductCode",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Stock_Size_SizeCode",
                        column: x => x.SizeCode,
                        principalTable: "Size",
                        principalColumn: "SizeCode",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Cart_ColorCode",
                table: "Cart",
                column: "ColorCode");

            migrationBuilder.CreateIndex(
                name: "IX_Cart_ProductCode",
                table: "Cart",
                column: "ProductCode");

            migrationBuilder.CreateIndex(
                name: "IX_Cart_SizeCode",
                table: "Cart",
                column: "SizeCode");

            migrationBuilder.CreateIndex(
                name: "IX_Cart_UserCode",
                table: "Cart",
                column: "UserCode");

            migrationBuilder.CreateIndex(
                name: "IX_MenuAccess_MenuCode",
                table: "MenuAccess",
                column: "MenuCode");

            migrationBuilder.CreateIndex(
                name: "IX_MenuAccess_RoleCode",
                table: "MenuAccess",
                column: "RoleCode");

            migrationBuilder.CreateIndex(
                name: "IX_Order_UserCode",
                table: "Order",
                column: "UserCode");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItem_ColorCode",
                table: "OrderItem",
                column: "ColorCode");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItem_OrderCode",
                table: "OrderItem",
                column: "OrderCode");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItem_ProductCode",
                table: "OrderItem",
                column: "ProductCode");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItem_SizeCode",
                table: "OrderItem",
                column: "SizeCode");

            migrationBuilder.CreateIndex(
                name: "IX_Product_BrandCode",
                table: "Product",
                column: "BrandCode");

            migrationBuilder.CreateIndex(
                name: "IX_Product_CategoryCode",
                table: "Product",
                column: "CategoryCode");

            migrationBuilder.CreateIndex(
                name: "IX_Product_UserCode",
                table: "Product",
                column: "UserCode");

            migrationBuilder.CreateIndex(
                name: "IX_RoleAccess_RoleCode",
                table: "RoleAccess",
                column: "RoleCode");

            migrationBuilder.CreateIndex(
                name: "IX_RoleAccess_UserCode",
                table: "RoleAccess",
                column: "UserCode");

            migrationBuilder.CreateIndex(
                name: "IX_RouteAccess_RoleCode",
                table: "RouteAccess",
                column: "RoleCode");

            migrationBuilder.CreateIndex(
                name: "IX_RouteAccess_RouteCode",
                table: "RouteAccess",
                column: "RouteCode");

            migrationBuilder.CreateIndex(
                name: "IX_Stock_ColorCode",
                table: "Stock",
                column: "ColorCode");

            migrationBuilder.CreateIndex(
                name: "IX_Stock_ProductCode",
                table: "Stock",
                column: "ProductCode");

            migrationBuilder.CreateIndex(
                name: "IX_Stock_SizeCode",
                table: "Stock",
                column: "SizeCode");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Cart");

            migrationBuilder.DropTable(
                name: "MenuAccess");

            migrationBuilder.DropTable(
                name: "OrderItem");

            migrationBuilder.DropTable(
                name: "RoleAccess");

            migrationBuilder.DropTable(
                name: "RouteAccess");

            migrationBuilder.DropTable(
                name: "Stock");

            migrationBuilder.DropTable(
                name: "Menu");

            migrationBuilder.DropTable(
                name: "Order");

            migrationBuilder.DropTable(
                name: "Route");

            migrationBuilder.DropTable(
                name: "UserRole");

            migrationBuilder.DropTable(
                name: "Color");

            migrationBuilder.DropTable(
                name: "Product");

            migrationBuilder.DropTable(
                name: "Size");

            migrationBuilder.DropTable(
                name: "Brand");

            migrationBuilder.DropTable(
                name: "Category");

            migrationBuilder.DropTable(
                name: "User");
        }
    }
}
