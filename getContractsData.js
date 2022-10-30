const fs = require("fs");
const playwright = require("playwright");
const dayjs = require("dayjs");
const readDataFromJSONFile = require('./readDataFromJSONFile')
const writeDataToJSONFile = require('./writeDataToJSONFile')

const main = () => {
  fs.readdir("./contracts", async (err, filenames) => {
    if (err) {
      console.error(err);
      return;
    }
    const database = readDataFromJSONFile('./database.json')
    const {lastSavedIndex, contractsData} = database
    const TOTAL_DATASET = filenames.length;
    const SELECTED_DATASET = 10;
    const filenamesSorted = filenames.sort();
    if(lastSavedIndex >= TOTAL_DATASET) {
      return
    }
    //get contracts detail
    for (filename of filenamesSorted.slice(lastSavedIndex + 1, TOTAL_DATASET)) {
      const contractAddress = filename.split("_")[0];
      const browser = await playwright.chromium.launch({ headless: false });
      try {
        const page = await browser.newPage();
        await page.goto(`https://etherscan.io/address/${contractAddress}`);
        const transactionCountText = await page
          .locator("#transactions > div.d-md-flex.align-items-center.mb-3 > p")
          .innerText();
        const transactionsDateText = await page
          .locator(
            "#transactions > div.table-responsive.mb-2.mb-md-0 > table > tbody > tr > td.showAge > span"
          )
          .first()
          .getAttribute("data-original-title");
        const transactionDate = dayjs(transactionsDateText).toDate();
        contractsData[contractAddress] = {
          txCount: Number(
            transactionCountText
              .split("from a total of ")[1]
              .split(" transactions")[0]
              .replace(",", "")
          ),
          txLatestDate: transactionDate,
          filename,
        };
        database.lastSavedIndex += 1
        writeDataToJSONFile(database, './database.json')
      } catch (err) {
        console.log(err);
      } finally {
        await browser.close();
      }
    }
    const objectAddressSortByTxCountArr = Object.entries(
      contractsData
    ).sort(([_, { txCount: txCountA }], [__, { txCount: txCountB }]) => {
      if (txCountA > txCountB) {
        return -1;
      } else if (txCountA < txCountB) {
        return 1;
      } else {
        return 0;
      }
    });
    const objectAddressSortByDateCountArr = Object.entries(
      contractsData
    ).sort(
      (
        [_, { txLatestDate: txLatestDateA }],
        [__, { txLatestDate: txLatestDateB }]
      ) => {
        if (dayjs(txLatestDateA).isAfter(txLatestDateB)) {
          return -1;
        } else if (dayjs(txLatestDateA).isBefore(txLatestDateB)) {
          return 1;
        } else {
          return 0;
        }
      }
    );
    try {
      fs.rmdirSync(
        "/Users/finstable5/work/master_degree/swat/top_contracts_tx_count"
      );
    } catch (err) {
      console.error(err);
    }
    // console.log(
    //   "objectAddressSortByTxCountArr.slice(0, SELECTED_DATASET).length",
    //   objectAddressSortByTxCountArr.slice(0, SELECTED_DATASET).length
    // );
    objectAddressSortByTxCountArr
      .slice(0, SELECTED_DATASET)
      .forEach((objectAddressSortByTxCount) => {
        fs.readFile(
          `./contracts/${objectAddressSortByTxCount[1].filename}`,
          "utf8",
          (err, data) => {
            if (err) {
              console.error(err);
              return;
            }
            fs.mkdir(
              `/Users/finstable5/work/master_degree/swat/top_contracts_tx_count`,
              { recursive: true },
              (err) => {
                if (err) throw err;
                fs.writeFileSync(
                  `/Users/finstable5/work/master_degree/swat/top_contracts_tx_count/${objectAddressSortByTxCount[0]}.sol`,
                  data
                );
              }
            );
          }
        );
      });
    try {
      fs.rmdirSync(
        "/Users/finstable5/work/master_degree/swat/top_contracts_latest_date"
      );
    } catch (err) {
      console.error(err);
    }
    // console.log(
    //   " objectAddressSortByDateCountArr.slice(0, SELECTED_DATASET).length",
    //   objectAddressSortByDateCountArr.slice(0, SELECTED_DATASET).length
    // );
    objectAddressSortByDateCountArr
      .slice(0, SELECTED_DATASET)
      .forEach((objectAddressSortByDateCount) => {
        fs.readFile(
          `./contracts/${objectAddressSortByDateCount[1].filename}`,
          "utf8",
          (err, data) => {
            if (err) {
              console.error(err);
              return;
            }
            fs.mkdir(
              `/Users/finstable5/work/master_degree/swat/top_contracts_latest_date`,
              { recursive: true },
              (err) => {
                if (err) throw err;
                fs.writeFileSync(
                  `/Users/finstable5/work/master_degree/swat/top_contracts_latest_date/${objectAddressSortByDateCount[0]}.sol`,
                  data
                );
              }
            );
          }
        );
      });
  });
};

main();
