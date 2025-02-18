using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StudentOglasi.Services.Migrations
{
    /// <inheritdoc />
    public partial class MakeProsjekOcjenaNullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<decimal>(
                name: "ProsjekOcjena",
                table: "PrijaveStipendija",
                type: "decimal(4,2)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(4,2)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<decimal>(
                name: "ProsjekOcjena",
                table: "PrijaveStipendija",
                type: "decimal(4,2)",
                nullable: false,
                defaultValue: 0m,
                oldClrType: typeof(decimal),
                oldType: "decimal(4,2)",
                oldNullable: true);
        }
    }
}
