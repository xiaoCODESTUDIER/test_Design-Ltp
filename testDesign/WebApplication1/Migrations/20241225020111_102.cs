using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace testDesign.Migrations
{
    /// <inheritdoc />
    public partial class _102 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "phoneNum",
                table: "userModel",
                type: "longtext",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "longtext")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AlterColumn<string>(
                name: "name",
                table: "userModel",
                type: "longtext",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "longtext")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "email",
                table: "userModel",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "useName",
                table: "userModel",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "email",
                table: "userModel");

            migrationBuilder.DropColumn(
                name: "useName",
                table: "userModel");

            migrationBuilder.UpdateData(
                table: "userModel",
                keyColumn: "phoneNum",
                keyValue: null,
                column: "phoneNum",
                value: "");

            migrationBuilder.AlterColumn<string>(
                name: "phoneNum",
                table: "userModel",
                type: "longtext",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "longtext",
                oldNullable: true)
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "userModel",
                keyColumn: "name",
                keyValue: null,
                column: "name",
                value: "");

            migrationBuilder.AlterColumn<string>(
                name: "name",
                table: "userModel",
                type: "longtext",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "longtext",
                oldNullable: true)
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }
    }
}
