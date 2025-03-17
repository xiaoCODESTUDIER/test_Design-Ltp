using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace testDesign.Migrations
{
    /// <inheritdoc />
    public partial class AddclassModel002 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "useid",
                table: "classModels",
                type: "longtext",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "useid",
                table: "classModels");
        }
    }
}
