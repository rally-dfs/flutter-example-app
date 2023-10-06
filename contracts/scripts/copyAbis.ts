const fsPromises = require("fs").promises;
const path = require("path");

async function main() {
  const filenames = [
    {
      src: "TestNFT.sol/TestNFT.json",
      dest: "TestNFT.json",
    },
  ];

  const sourceDir = path.join(__dirname, "../artifacts/contracts/");

  const targetDir = path.join(__dirname, "../../app/lib/contracts/");

  filenames.forEach(async (filename) => {
    const sourceFilePath = path.join(sourceDir, filename.src);
    const targetFilePath = path.join(targetDir, filename.dest);

    await fsPromises.copyFile(sourceFilePath, targetFilePath);
  });
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
