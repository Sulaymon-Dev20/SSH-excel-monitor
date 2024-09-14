function fetchDataAndUpdate() {
    const url = 'https://server.ofnur.com/ssh-logs';
    const sheetName = "165.232.136.191"; // Define the sheet name here
    createSheet(url, sheetName);
}

function createSheet(url, sheetName) {
    const res = UrlFetchApp.fetch(url);
    const data = JSON.parse(res.getContentText());
    const results = data.map(item => [item.time, item.ssh_connection.remote_ip, item.ssh_user, item.pid, item.active]).reverse();

    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    let sheet = spreadsheet.getSheetByName(sheetName);

    if (!sheet) {
        // If the sheet doesn't exist, create it
        sheet = spreadsheet.insertSheet(sheetName);
    } else {
        // If the sheet exists, clear it (optional)
        sheet.clear();
    }

    // Set headers in the first row
    const headers = [["Time", "IP4v", "User", "PID", "Active"]];
    sheet.getRange(1, 1, 1, headers[0].length).setValues(headers);

    // Set values starting from the second row
    const range = sheet.getRange(2, 1, results.length, results[0].length);
    range.setValues(results);

    // Apply background color to the header row
    const headerRange = sheet.getRange(1, 1, 1, headers[0].length);
    headerRange.setBackground('#f0f0f0'); // Example background color

    // Set column widths (adjust as needed)
    sheet.setColumnWidth(1, 200); // Adjust column widths in pixels
    sheet.setColumnWidth(2, 150);
    sheet.setColumnWidth(3, 150);
    sheet.setColumnWidth(4, 100);
    sheet.setColumnWidth(5, 100); // Column for 'Active'


    // Set text alignment to start from left to right
    range.setHorizontalAlignment('left');

    // Set vertical alignment and text wrapping
    range.setVerticalAlignment('middle');
    range.setWrap(true);

    // Apply conditional formatting for background color based on PID being a number
    const pidRule = SpreadsheetApp.newConditionalFormatRule()
        .whenFormulaSatisfied('=ISNUMBER($D2)')
        .setBackground('#e6ffe6')
        .setRanges([range])
        .build();

    const rules = sheet.getConditionalFormatRules();
    rules.push(pidRule);

    // Apply conditional formatting for bold text based on 'Active' column being true
    const boldRule = SpreadsheetApp.newConditionalFormatRule()
        .whenFormulaSatisfied('=$E2=TRUE') // Assuming 'Active' column is E
        .setBold(true)
        .setRanges([range])
        .build();

    rules.push(boldRule);
    sheet.setConditionalFormatRules(rules);


    const users = sheet.getRange(1, 3, results.length + 1).getValues();
    users.shift();
    const countMap = new Map();
    users.forEach(item => {
        countMap.set(item[0], (countMap.get(item[0]) || 0) + 1);
    });
    const rows = Array.from(countMap.entries());
    sheet.getRange(1, results[0].length + 2, 1, 2).setValues([['Users', 'usage of user']]);
    sheet.getRange(2, results[0].length + 2, rows.length, 2).setValues(rows);

    var pieChartTitle = "Usernames and Connection Counts";
    var pieChartBuilder = sheet.newChart()
        .addRange(sheet.getRange("G2:H4"))
        .setChartType(Charts.ChartType.PIE)
        .setOption('pieSliceText', 'value')
        .setPosition(1, 7, 0, 0)
        .setOption('title', pieChartTitle)
        .setOption('width', 500).setOption('height', 313)
        .setOption('pieHole', 0.5)
        .build();


    const ips = sheet.getRange(1, 2, results.length + 1).getValues();
    ips.shift();
    const countIps = new Map();
    ips.forEach(item => {
        countIps.set(item[0], (countIps.get(item[0]) || 0) + 1);
    });
    const iprows = Array.from(countIps.entries());
    sheet.getRange(1, results[0].length + 4, 1, 2).setValues([['IP4v', 'count of usage']]);
    sheet.getRange(2, results[0].length + 4, iprows.length, 2).setValues(iprows);


    var apiChartBuilder = sheet.newChart()
        .addRange(sheet.getRange("I2:J4"))
        .setChartType(Charts.ChartType.PIE)
        .setOption('pieSliceText', 'value')
        .setPosition(16, 7, 0, 0)
        .setOption('title', "IP4v usage")
        .setOption('width', 500).setOption('height', 313)
        .build();

    sheet.getRange('G:J').setFontColor('#FFF'); // You can change the hex code to any color you want

    if (sheet.getCharts().length === 0) {
        sheet.insertChart(apiChartBuilder);
        sheet.insertChart(pieChartBuilder);
    }
}