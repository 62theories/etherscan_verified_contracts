const fs = require("fs");
const { exec } = require("child_process");
// const playwright = require("playwright");
// const dayjs = require("dayjs");

const main = () => {
  fs.readdir(
    "/Users/finstable5/work/master_degree/swat/top_contracts_tx_count",
    async (err, filenames) => {
      if (err) {
        console.error(err);
        return;
      }
      filenames.forEach((fileName) => {
        if (!fileName.includes(".sol")) {
          return;
        }
        const swcList = [
          "swc100",
          "swc102",
          "swc103",
          "swc111",
          "swc129",
          "swc134",
        ];
        swcList.forEach((swcName) => {
          exec(
            `python3 /Users/finstable5/work/master_degree/swat/lothric_no_gui.py -i /Users/finstable5/work/master_degree/swat/top_contracts_tx_count/${fileName} -d ${swcName}`,
            (error, stdout, stderr) => {
              if (error) {
                console.log(`error: ${error.message}`);
                return;
              }
              if (stderr) {
                console.log(`stderr: ${stderr}`);
                return;
              }
              let result = true;
              if (stdout.includes("not found")) {
                result = false;
              }
              const folderName = `./results/${
                fileName.split(".sol")[0]
              }/${swcName}`;
              fs.mkdir(`${folderName}`, { recursive: true }, (err) => {
                if (err) throw err;
                fs.writeFileSync(
                  `${folderName}/swat.json`,
                  `{"detected": ${result}}`
                );
              });
            }
          );
        });
      });
      fs.readdir(
        "/Users/finstable5/work/master_degree/swat/top_contracts_latest_date",
        async (err, filenames) => {
          if (err) {
            console.error(err);
            return;
          }
          filenames.forEach((fileName) => {
            if (!fileName.includes(".sol")) {
              return;
            }
            const swcList = [
              "swc100",
              "swc102",
              "swc103",
              "swc111",
              "swc129",
              "swc134",
            ];
            swcList.forEach((swcName) => {
              exec(
                `python3 /Users/finstable5/work/master_degree/swat/lothric_no_gui.py -i /Users/finstable5/work/master_degree/swat/top_contracts_latest_date/${fileName} -d ${swcName}`,
                (error, stdout, stderr) => {
                  if (error) {
                    console.log(`error: ${error.message}`);
                    return;
                  }
                  if (stderr) {
                    console.log(`stderr: ${stderr}`);
                    return;
                  }
                  let result = true;
                  if (stdout.includes("not found")) {
                    result = false;
                  }
                  const folderName = `./results/${
                    fileName.split(".sol")[0]
                  }/${swcName}`;
                  fs.mkdir(`${folderName}`, { recursive: true }, (err) => {
                    if (err) throw err;
                    fs.writeFileSync(
                      `${folderName}/swat.json`,
                      `{"detected": ${result}}`
                    );
                  });
                }
              );
            });
          });
        }
      );
    }
  );
};

main();
