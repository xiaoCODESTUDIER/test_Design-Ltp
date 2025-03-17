using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace testDesign.Migrations
{
    /// <inheritdoc />
    public partial class AddclassModel004 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "contents",
                table: "classModels",
                newName: "goodsid");

            migrationBuilder.AddColumn<string>(
                name: "contentid",
                table: "classModels",
                type: "longtext",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "contentModels",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    contentid = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Useid = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Commnet = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    CommentDate = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    goodsid = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    classModelid = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contentModels", x => x.id);
                    table.ForeignKey(
                        name: "FK_contentModels_classModels_classModelid",
                        column: x => x.classModelid,
                        principalTable: "classModels",
                        principalColumn: "id");
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "goodModels",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    useid = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    goods = table.Column<int>(type: "int", nullable: false),
                    bads = table.Column<int>(type: "int", nullable: false),
                    goodsDate = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    classModelid = table.Column<int>(type: "int", nullable: true),
                    contentModelid = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_goodModels", x => x.id);
                    table.ForeignKey(
                        name: "FK_goodModels_classModels_classModelid",
                        column: x => x.classModelid,
                        principalTable: "classModels",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_goodModels_contentModels_contentModelid",
                        column: x => x.contentModelid,
                        principalTable: "contentModels",
                        principalColumn: "id");
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "IX_contentModels_classModelid",
                table: "contentModels",
                column: "classModelid");

            migrationBuilder.CreateIndex(
                name: "IX_goodModels_classModelid",
                table: "goodModels",
                column: "classModelid");

            migrationBuilder.CreateIndex(
                name: "IX_goodModels_contentModelid",
                table: "goodModels",
                column: "contentModelid");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "goodModels");

            migrationBuilder.DropTable(
                name: "contentModels");

            migrationBuilder.DropColumn(
                name: "contentid",
                table: "classModels");

            migrationBuilder.RenameColumn(
                name: "goodsid",
                table: "classModels",
                newName: "contents");
        }
    }
}
