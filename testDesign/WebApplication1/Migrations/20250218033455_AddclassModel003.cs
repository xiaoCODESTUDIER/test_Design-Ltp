using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace testDesign.Migrations
{
    /// <inheritdoc />
    public partial class AddclassModel003 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "contentsnum",
                table: "classModels",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "eyes",
                table: "classModels",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "contentsnum",
                table: "classModels");

            migrationBuilder.DropColumn(
                name: "eyes",
                table: "classModels");
        }
    }
}
