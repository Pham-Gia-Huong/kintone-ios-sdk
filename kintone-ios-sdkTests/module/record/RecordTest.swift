//
//  Record.swift
//  kintone-ios-sdkTests
//
//  Created by t000572 on 2018/10/01.
//  Copyright © 2018年 Cybozu. All rights reserved.
//

import XCTest
@testable import kintone_ios_sdk
@testable import Promises

class RecordTest: XCTestCase {
    
    private let API_TOKEN = "vXpZuik6FwetdecNVUzEfQCR3F1cu2qoJZMFXyOe"
    private let APP_ID = 9
    
    private let testUser1 = Member("user1", "user1")
    private let testUser2 = Member("user2", "user2")
    private let testOrg1 = Member("test", "テスト組織")
    private let testOrg2 = Member("検証組織", "検証組織")
    private let testGroup1 = Member("TeamA", "チームA")
    private let testGroup2 = Member("TeamB", "チームB")
    private let testAdmin = Member("Administrator", "Administrator")
    
    private var recordManagement: Record?
    
    override func setUp() {
        super.setUp()
        
        // set auth
        var auth = Auth()
        auth = auth.setPasswordAuth("cybozu", "cybozu")
        let conn = Connection( "phienphamf1811-1.cybozu-dev.com", auth )
        conn.setProxy("dc-ty3-squid-1.cb.local", 3128)
        
        // instance of Record class
        self.recordManagement = Record(conn)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getErrorMessage(_ error: Any) -> String {
        if error is KintoneAPIException {
            return (error as! KintoneAPIException).toString()!
        }
        else {
            return (error as! Error).localizedDescription
        }
    }
    
    func testGetRecord() throws {
        // create test data for get record
        var testData: Dictionary<String, FieldValue> = createAddData()
        testData = addData(testData, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordSuccess")
        
        try self.recordManagement?.addRecord(self.APP_ID, testData).then{addResponse in
            let recNum = addResponse.getId()
            try self.recordManagement?.getRecord(self.APP_ID, recNum!).then{ getResponse in
                let resultData: Dictionary<String, FieldValue> = getResponse.getRecord()!
                // check result
                for (code, value) in resultData {
                    let resultFieldType = value.getType()
                    let resultFieldValue = value.getValue()
                    let testDataValue = testData[code]?.getValue()
                    
                    // check exec result
                    self.checkResult(resultFieldType!, resultFieldValue as Any, testDataValue as Any)
                }
            }
            XCTAssert(waitForPromises(timeout: 5))
        }.catch{ error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testGetRecords() throws {
        
        // create test data for get record
        var testData1: Dictionary<String, FieldValue> = createAddData()
        var testData2: Dictionary<String, FieldValue> = createAddData()
        var testData3: Dictionary<String, FieldValue> = createAddData()
        testData1 = addData(testData1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecords1")
        testData2 = addData(testData2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecords2")
        testData3 = addData(testData3, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecords3")
        var testDatas = [testData1, testData2, testData3]
        
        try self.recordManagement?.addRecords(self.APP_ID, testDatas).then{addResponse in
            let recIds = addResponse.getIDs()
            let query = "レコード番号 >= " + recIds![0].description + " order by レコード番号 asc"
            try self.recordManagement?.getRecords(self.APP_ID, query, nil, true).then{ getResponse in
                let resultData = getResponse.getRecords()!
                // check result
                for (i, dval) in (resultData.enumerated()) {
                    for (code, value) in dval {
                        let resultFieldType = value.getType()
                        let resultFieldValue = value.getValue()
                        let testDataValue = testDatas[i][code]?.getValue()
                        self.checkResult(resultFieldType!, resultFieldValue as Any, testDataValue as Any)
                    }
                }
            }
            XCTAssert(waitForPromises(timeout: 5))
        }.catch{ error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testGetRecordsWithoutApp() throws {
        // exec get record test
        try self.recordManagement?.getRecords(99999999, nil, nil, true).catch{ error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testGetRecordsWithQuery() throws {
        // create test data for get record
        var testData1: Dictionary<String, FieldValue> = createAddData()
        var testData2: Dictionary<String, FieldValue> = createAddData()
        var testData3: Dictionary<String, FieldValue> = createAddData()
        testData1 = addData(testData1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithQuery1")
        testData2 = addData(testData2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithQuery2")
        testData3 = addData(testData3, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithQuery3")
        var testDatas = [testData1, testData2, testData3]
        
        try self.recordManagement?.addRecords(self.APP_ID, testDatas).then{ addResponse in
            let recIds = addResponse.getIDs()
            let query = "NUMBER >= 2000 and レコード番号 >= " + recIds![0].description + " order by レコード番号 asc"
            try self.recordManagement?.getRecords(self.APP_ID, query, nil, true).then{response in
                let resultData = response.getRecords()
                // check result
                for (i, dval) in (resultData!.enumerated()) {
                    for (code, value) in dval {
                        let resultFieldType = value.getType()
                        let resultFieldValue = value.getValue()
                        let testDataValue = testDatas[i][code]?.getValue()
                        self.checkResult(resultFieldType!, resultFieldValue as Any, testDataValue as Any)
                    }
                }
            }
        }.catch{ error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testGetRecordsWithFields() throws {
        let fields = ["SINGLE_LINE_TEXT", "DROP_DOWN"]
        
        // create test data for get record
        var testData1: Dictionary<String, FieldValue> = createAddData()
        var testData2: Dictionary<String, FieldValue> = createAddData()
        var testData3: Dictionary<String, FieldValue> = createAddData()
        testData1 = addData(testData1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithFields1")
        testData2 = addData(testData2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithFields2")
        testData3 = addData(testData3, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithFields3")
        var testDatas = [testData1, testData2, testData3]
        
        try self.recordManagement?.addRecords(self.APP_ID, testDatas).then{addResponse in
            let recIds = addResponse.getIDs()
            let query = "NUMBER >= 2000 and レコード番号 >= " + recIds![0].description + " order by レコード番号 asc"
            try self.recordManagement?.getRecords(self.APP_ID, query, fields, true).then{response in
                let resultData = response.getRecords()
                // check result
                for (i, dval) in (resultData?.enumerated())! {
                    XCTAssertEqual(2, dval.count)
                    for (code, value) in dval {
                        let resultFieldType = value.getType()
                        let resultFieldValue = value.getValue()
                        let testDataValue = testDatas[i][code]?.getValue()
                        self.checkResult(resultFieldType!, resultFieldValue as Any, testDataValue as Any)
                    }
                }
            }
        }.catch{ error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testGetRecordsWithoutTotal() throws {
        // create test data for get record
        var testData1: Dictionary<String, FieldValue> = createAddData()
        var testData2: Dictionary<String, FieldValue> = createAddData()
        var testData3: Dictionary<String, FieldValue> = createAddData()
        testData1 = addData(testData1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithoutTotal1")
        testData2 = addData(testData2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithoutTotal2")
        testData3 = addData(testData3, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testGetRecordsWithoutTotal3")
        var testDatas = [testData1, testData2, testData3]
        
        try self.recordManagement?.addRecords(self.APP_ID, testDatas).then{addResponse in
            let recIds = addResponse.getIDs()
            let query = "レコード番号 >= " + recIds![0].description + " order by レコード番号 asc"
            try self.recordManagement?.getRecords(self.APP_ID, query, nil, nil).then{response in
                let resultData = response.getRecords()
                
                // check result
                XCTAssertNil(response.getTotalCount())
                for (i, dval) in (resultData?.enumerated())! {
                    for (code, value) in dval {
                        let resultFieldType = value.getType()
                        let resultFieldValue = value.getValue()
                        let testDataValue = testDatas[i][code]?.getValue()
                        self.checkResult(resultFieldType!, resultFieldValue as Any, testDataValue as Any)
                    }
                }
            }
        }.catch{ error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testAddRecord() throws {
        // create test data for add
        var testData: Dictionary<String, FieldValue> = createAddData()
        testData = addData(testData, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testAddRecord")
        
        try self.recordManagement?.addRecord(self.APP_ID, testData).then{response in
            XCTAssertNotNil(response.getId())
            XCTAssertNotNil(response.getRevision())
        }.catch {error in
            XCTFail(self.getErrorMessage(error))
        }
        
    }
    
    func testAddRecordWithoutRecord() throws {
        try self.recordManagement?.addRecord(self.APP_ID, nil).then{response in
            XCTAssertNotNil(response.getId())
            XCTAssertNotNil(response.getRevision())
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testAddRecords() throws {
        // create test data for addRecords
        var testData1: Dictionary<String, FieldValue> = createAddData()
        var testData2: Dictionary<String, FieldValue> = createAddData()
        testData1 = addData(testData1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testAddRecordsS1")
        testData2 = addData(testData2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testAddRecords2")
        let testDataList = [testData1, testData2]
        
        try self.recordManagement?.addRecords(self.APP_ID, testDataList).then{response in
            XCTAssertEqual(2, response.getIDs()?.count)
            XCTAssertEqual(2, response.getRevisions()?.count)
            XCTAssertNotNil(response.getIDs()![0])
            XCTAssertNotNil(response.getIDs()![1])
            XCTAssertNotNil(response.getRevisions()![0])
            XCTAssertNotNil(response.getRevisions()![1])
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordById() throws {
        // create test data for update
        var updRecord = createAddData()
        try self.recordManagement?.addRecord(self.APP_ID, updRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            updRecord = self.addData(updRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testUpdateRecordById")
            try self.recordManagement?.updateRecordByID(self.APP_ID, updRecNum!, updRecord, updRevision).then{response in
                XCTAssertEqual(updRevision!+1, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordByIdWithoutRevision() throws {
        // create test data for update
        var updRecord = createAddData()
        try self.recordManagement?.addRecord(self.APP_ID, updRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            updRecord = self.addData(updRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordByIdWithoutRevision")
            try self.recordManagement?.updateRecordByID(self.APP_ID, updRecNum!, updRecord, nil).then{response in
                XCTAssertEqual(updRevision!+1, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordByIdWithoutRecord() throws {
        // create test data for update
        var updRecord = createAddData()
        try self.recordManagement?.addRecord(self.APP_ID, updRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            updRecord = self.addData(updRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordByIdWithoutRecord")
            try self.recordManagement?.updateRecordByID(self.APP_ID, updRecNum!, nil, nil).then{response in
                XCTAssertEqual(updRevision!+1, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordByUpdateKey() throws {
        // create unique key
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let uniquekey = formatter.string(from: now as Date) + (Int(arc4random_uniform(1000000) + 1)).description
        
        // create test data for update
        var addRecord = createAddData()
        addRecord = addData(addRecord, "UPDATE_KEY", FieldType.SINGLE_LINE_TEXT, uniquekey)
        try self.recordManagement?.addRecord(self.APP_ID, addRecord).then{addResponse in
            let updRevision = addResponse.getRevision()
            let updKey: RecordUpdateKey = RecordUpdateKey("UPDATE_KEY", uniquekey)
            var updRecord: Dictionary<String, FieldValue> = [:]
            updRecord = self.addData(updRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordByUpdateKey")
            try self.recordManagement?.updateRecordByUpdateKey(self.APP_ID, updKey, updRecord, nil).then{response in
                XCTAssertEqual(updRevision!+1, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordByUpdateKeyWithoutRecord() throws {
        // create unique key
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let uniquekey = formatter.string(from: now as Date) + (Int(arc4random_uniform(1000000) + 1)).description
        
        // create test data for update
        var addRecord = createAddData()
        addRecord = addData(addRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordByUpdateKeyWithoutRecord")
        addRecord = addData(addRecord, "UPDATE_KEY", FieldType.SINGLE_LINE_TEXT, uniquekey)
        try self.recordManagement?.addRecord(self.APP_ID, addRecord).then{addResponse in
            let updRevision = addResponse.getRevision()
            let updKey: RecordUpdateKey = RecordUpdateKey("UPDATE_KEY", uniquekey)
            try self.recordManagement?.updateRecordByUpdateKey(self.APP_ID, updKey, nil, nil).then{response in
                XCTAssertEqual(updRevision!+1, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecords() throws {
        // create test data for update
        var addRecord1 = createAddData()
        var addRecord2 = createAddData()
        let addRecordList = [addRecord1, addRecord2]
        try self.recordManagement?.addRecords(self.APP_ID, addRecordList).then{addResponse in
            // update data
            addRecord1 = self.addData(addRecord1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testUpdateRecords1")
            addRecord2 = self.addData(addRecord2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "testUpdateRecords2")
            let updItem1: RecordUpdateItem = RecordUpdateItem(addResponse.getIDs()?[0], nil, nil, addRecord1)
            let updItem2: RecordUpdateItem = RecordUpdateItem(addResponse.getIDs()?[1], nil, nil, addRecord2)
            let updItemList = [updItem1, updItem2]
            
            try self.recordManagement?.updateRecords(self.APP_ID, updItemList).then{response in
                XCTAssertEqual(2, response.getRecords()?.count)
                XCTAssertEqual((response.getRecords()![0]).getID(), addResponse.getIDs()![0])
                XCTAssertEqual((response.getRecords()![1]).getID(), addResponse.getIDs()![1])
                XCTAssertEqual((response.getRecords()![0]).getRevision(), addResponse.getRevisions()![0]+1)
                XCTAssertEqual((response.getRecords()![1]).getRevision(), addResponse.getRevisions()![1]+1)
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testDeleteRecords() throws {
        // create test data for delete
        let delRecord1 = createAddData()
        let delRecord2 = createAddData()
        let delRecordList = [delRecord1, delRecord2]
        try self.recordManagement?.addRecords(self.APP_ID, delRecordList).then{addResponse in
            let delId = [addResponse.getIDs()![0], addResponse.getIDs()![1]]
            try self.recordManagement?.deleteRecords(self.APP_ID, delId)
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testDeleteRecordsWithRevision() throws {
        // create test data for delete
        let delRecord1 = createAddData()
        let delRecord2 = createAddData()
        let delRecordList = [delRecord1, delRecord2]
        try self.recordManagement?.addRecords(self.APP_ID, delRecordList).then{addResponse in
            var delIdAndRevision: Dictionary<Int, Int> = [:]
            delIdAndRevision[addResponse.getIDs()![0]] = addResponse.getRevisions()![0]
            delIdAndRevision[addResponse.getIDs()![1]] = addResponse.getRevisions()![1]
            try self.recordManagement?.deleteRecordsWithRevision(self.APP_ID, delIdAndRevision)
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testDeleteRecordsWithRevisionWithoutRevision() throws {
        // create test data for delete
        var delRecord1 = createAddData()
        var delRecord2 = createAddData()
        delRecord1 = addData(delRecord1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testDeleteRecordsWithRevisionWithoutRevision1")
        delRecord2 = addData(delRecord2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testDeleteRecordsWithRevisionWithoutRevision2")
        let delRecordList = [delRecord1, delRecord2]
        try self.recordManagement?.addRecords(self.APP_ID, delRecordList).then{addResponse in
            var delIdAndRevision: Dictionary<Int, Int> = [:]
            delIdAndRevision[addResponse.getIDs()![0]] = nil
            delIdAndRevision[addResponse.getIDs()![1]] = nil
            try self.recordManagement?.deleteRecordsWithRevision(self.APP_ID, delIdAndRevision)
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordAssignees() throws {
        // create test data for update assignees
        var updAssigneesRecord = createAddData()
        updAssigneesRecord = addData(updAssigneesRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordAssignees")
        try self.recordManagement?.addRecord(self.APP_ID, updAssigneesRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            let assignees: Array<String> = [self.testUser1.code!]
            
            try self.recordManagement?.updateRecordAssignees(self.APP_ID, updRecNum!, assignees, updRevision).then{response in
                XCTAssertEqual(updRevision!+1, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordAssigneesWithoutRevision() throws {
        // create test data for update assignee
        var updAssigneesRecord = createAddData()
        updAssigneesRecord = addData(updAssigneesRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordAssigneesWithoutRevision")
        
        try self.recordManagement?.addRecord(self.APP_ID, updAssigneesRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            let assignees: Array<String> = [self.testUser1.code!]
            
            try self.recordManagement?.updateRecordAssignees(self.APP_ID, updRecNum!, assignees, nil).then{response in
                XCTAssertEqual(updRevision!+1, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordStatus() throws {
        // create test data for update status
        var updStatusRecord = createAddData()
        updStatusRecord = addData(updStatusRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordStatus")
        
        try self.recordManagement?.addRecord(self.APP_ID, updStatusRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            let assignee = self.testUser1.code
            let status = "処理開始"
            
            try self.recordManagement?.updateRecordStatus(self.APP_ID, updRecNum!, status, assignee, updRevision).then{response in
                XCTAssertEqual(updRevision!+2, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordStatusWithoutRevision() throws {
        // create test data for update status
        var updStatusRecord = createAddData()
        updStatusRecord = addData(updStatusRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordStatusWithoutRevision")
        try self.recordManagement?.addRecord(self.APP_ID, updStatusRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            let assignee = self.testUser2.code
            let status = "処理開始"
            try self.recordManagement?.updateRecordStatus(self.APP_ID, updRecNum!, status, assignee, nil).then{response in
                XCTAssertEqual(updRevision!+2, response.getRevision())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordStatusWithoutAssignee() throws {
        // create test data for update status
        var updStatusRecord = createAddData()
        updStatusRecord = addData(updStatusRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordStatusWithoutAssignee")
        try self.recordManagement?.addRecord(self.APP_ID, updStatusRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let updRevision = addResponse.getRevision()
            let status = "処理開始"
            
            try self.recordManagement?.updateRecordStatus(self.APP_ID, updRecNum!, status, nil, updRevision)
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordsStatus() throws {
        // create test data for update status
        var updStatusRecord1 = createAddData()
        var updStatusRecord2 = createAddData()
        updStatusRecord1 = addData(updStatusRecord1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordsStatus1")
        updStatusRecord2 = addData(updStatusRecord2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordsStatus2")
        
        let updsStatus = [updStatusRecord1, updStatusRecord2]
        try self.recordManagement?.addRecords(self.APP_ID, updsStatus).then{addResponse in
            let id1 = addResponse.getIDs()![0]
            let id2 = addResponse.getIDs()![1]
            let revision1 = addResponse.getRevisions()![0]
            let revision2 = addResponse.getRevisions()![1]
            let item1: RecordUpdateStatusItem = RecordUpdateStatusItem("処理開始", self.testUser1.code, id1, revision1)
            let item2: RecordUpdateStatusItem = RecordUpdateStatusItem("処理開始", self.testUser2.code, id2, revision2)
            let itemList = [item1, item2]
            try self.recordManagement?.updateRecordsStatus(self.APP_ID, itemList).then{response in
                XCTAssertEqual(2, response.getRecords()?.count)
                XCTAssertEqual((response.getRecords()![0]).getID(), addResponse.getIDs()![0])
                XCTAssertEqual((response.getRecords()![1]).getID(), addResponse.getIDs()![1])
                XCTAssertEqual((response.getRecords()![0]).getRevision(), addResponse.getRevisions()![0]+2)
                XCTAssertEqual((response.getRecords()![1]).getRevision(), addResponse.getRevisions()![1]+2)
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testUpdateRecordsStatusWithoutReivision() throws {
        // create test data for update status
        var updStatusRecord1 = createAddData()
        var updStatusRecord2 = createAddData()
        updStatusRecord1 = addData(updStatusRecord1, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordsStatusWithoutReivision1")
        updStatusRecord2 = addData(updStatusRecord2, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testUpdateRecordsStatusWithoutReivision2")
        
        let updsStatus = [updStatusRecord1, updStatusRecord2]
        try self.recordManagement?.addRecords(self.APP_ID, updsStatus).then{addResponse in
            let id1 = addResponse.getIDs()![0]
            let id2 = addResponse.getIDs()![1]
            let item1: RecordUpdateStatusItem = RecordUpdateStatusItem("処理開始", self.testUser1.code, id1, nil)
            let item2: RecordUpdateStatusItem = RecordUpdateStatusItem("処理開始", self.testUser2.code, id2, nil)
            let itemList = [item1, item2]
            
            try self.recordManagement?.updateRecordsStatus(self.APP_ID, itemList).then{response in
                XCTAssertEqual(2, response.getRecords()?.count)
                XCTAssertEqual((response.getRecords()![0]).getID(), addResponse.getIDs()![0])
                XCTAssertEqual((response.getRecords()![1]).getID(), addResponse.getIDs()![1])
                XCTAssertEqual((response.getRecords()![0]).getRevision(), addResponse.getRevisions()![0]+2)
                XCTAssertEqual((response.getRecords()![1]).getRevision(), addResponse.getRevisions()![1]+2)
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testAddComment() throws {
        // create test data for add comment
        var addCommentRecord = createAddData()
        addCommentRecord = addData(addCommentRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testAddComment")
        try self.recordManagement?.addRecord(self.APP_ID, addCommentRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let mention = CommentMention()
            let comment = CommentContent()
            mention.setCode(self.testUser1.code!)
            mention.setType("USER")
            let mentionList = [mention]
            comment.setText("add comment test")
            comment.setMentions(mentionList)
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment).then{response in
                XCTAssertNotNil(response.getId())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testAddCommentWithoutMention() throws {
        // create test data for add comment
        var addCommentRecord = createAddData()
        addCommentRecord = addData(addCommentRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testAddCommentWithoutMention")
        try self.recordManagement?.addRecord(self.APP_ID, addCommentRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let comment = CommentContent()
            comment.setText("add comment without mention test")
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment).then{response in
                XCTAssertNotNil(response.getId())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testGetComments() throws {
        // create test data for get comments
        var addCommentRecord = createAddData()
        addCommentRecord = addData(addCommentRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testGetComments")
        try self.recordManagement?.addRecord(self.APP_ID, addCommentRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let mention = CommentMention()
            let comment = CommentContent()
            mention.setCode(self.testUser1.code!)
            mention.setType("USER")
            let mentionList = [mention]
            comment.setText("add comment test1")
            comment.setMentions(mentionList)
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            comment.setText("add comment test2")
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            comment.setText("add comment test3")
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            comment.setText("add comment test4")
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            try self.recordManagement?.getComments(self.APP_ID, updRecNum!, "asc", 1, 2).then{response in
                XCTAssertEqual(2, response.getComments()?.count)
                XCTAssertNotNil(response.getComments()![0].getId())
                XCTAssertNotNil(response.getComments()![1].getId())
                XCTAssertNotNil(response.getComments()![0].getCreatedAt())
                XCTAssertNotNil(response.getComments()![1].getCreatedAt())
                XCTAssertEqual(self.testUser1.name! + " \nadd comment test2 ", response.getComments()![0].getText())
                XCTAssertEqual(self.testUser1.name! + " \nadd comment test3 ", response.getComments()![1].getText())
                XCTAssertEqual(self.testAdmin.code, response.getComments()![0].getCreator()?.code)
                XCTAssertEqual(self.testAdmin.code, response.getComments()![1].getCreator()?.code)
                XCTAssertEqual(mention.getCode(), response.getComments()![0].getMentions()![0].getCode())
                XCTAssertEqual(mention.getCode(), response.getComments()![1].getMentions()![0].getCode())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testGetCommentsWithoutOption() throws {
        // create test data for get comments
        var addCommentRecord = createAddData()
        addCommentRecord = addData(addCommentRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testGetCommentsWithoutOption")
        try self.recordManagement?.addRecord(self.APP_ID, addCommentRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let mention = CommentMention()
            let comment = CommentContent()
            mention.setCode(self.testUser1.code!)
            mention.setType("USER")
            let mentionList = [mention]
            comment.setText("add comment test1")
            comment.setMentions(mentionList)
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            comment.setText("add comment test2")
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            comment.setText("add comment test3")
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            comment.setText("add comment test4")
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment)
            try self.recordManagement?.getComments(self.APP_ID, updRecNum!, nil, nil, nil).then{response in
                XCTAssertEqual(4, response.getComments()?.count)
                XCTAssertNotNil(response.getComments()![0].getId())
                XCTAssertNotNil(response.getComments()![0].getCreatedAt())
                XCTAssertEqual(self.testUser1.name! + " \nadd comment test4 ", response.getComments()![0].getText())
                XCTAssertEqual(self.testAdmin.code, response.getComments()![0].getCreator()?.code)
                XCTAssertEqual(mention.getCode(), response.getComments()![0].getMentions()![0].getCode())
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    func testDeleteComment() throws {
        // create test data for delete comment
        var delCommentRecord = createAddData()
        delCommentRecord = addData(delCommentRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, " testDeleteComment")
        try self.recordManagement?.addRecord(self.APP_ID, delCommentRecord).then{addResponse in
            let updRecNum = addResponse.getId()
            let mention = CommentMention()
            let comment = CommentContent()
            mention.setCode(self.testUser1.code!)
            mention.setType("USER")
            let mentionList = [mention]
            comment.setText("delete comment test")
            comment.setMentions(mentionList)
            try self.recordManagement?.addComment(self.APP_ID, updRecNum!, comment).then{addComResponse in
                try self.recordManagement?.deleteComment(self.APP_ID, updRecNum!, addComResponse.getId()!)
            }
        }.catch{error in
            XCTFail(self.getErrorMessage(error))
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    private func createAddData() -> Dictionary<String, FieldValue> {
        var testRecord: Dictionary<String, FieldValue> = [:]
        
        // text type
        testRecord = addData(testRecord, "SINGLE_LINE_TEXT", FieldType.SINGLE_LINE_TEXT, "single line text add data")
        testRecord = addData(testRecord, "UPDATE_KEY", FieldType.SINGLE_LINE_TEXT, "")
        testRecord = addData(testRecord, "MULTI_LINE_TEXT", FieldType.MULTI_LINE_TEXT, "multi line text add data1\nmulti line text add data2")
        testRecord = addData(testRecord, "RICH_TEXT", FieldType.RICH_TEXT, "<div><strong>rich text test add</strong></div>")
        
        let uniqunum = arc4random() % 10
        testRecord = addData(testRecord, "NUMBER", FieldType.NUMBER, uniqunum.description)
        
        // select type
        let selectMultiData = ["sample1", "sample2"]
        testRecord = addData(testRecord, "RADIO_BUTTON", FieldType.RADIO_BUTTON, "sample1")
        testRecord = addData(testRecord, "CHECK_BOX", FieldType.CHECK_BOX, selectMultiData)
        testRecord = addData(testRecord, "MULTI_SELECT", FieldType.MULTI_SELECT, selectMultiData)
        testRecord = addData(testRecord, "DROP_DOWN", FieldType.DROP_DOWN, "sample2")
        testRecord = addData(testRecord, "DATE", FieldType.DATE, "2019-01-01")
        testRecord = addData(testRecord, "TIME", FieldType.TIME, "08:14")
        testRecord = addData(testRecord, "DATETIME", FieldType.DATETIME, "2019-01-01T02:30:00Z")
        
        // user select type
        let selectUserData: [Member] = [self.testUser1, self.testUser2]
        let selectOrgData: [Member] = [self.testOrg1, self.testOrg2]
        let selectGroupData: [Member] = [self.testGroup1, self.testGroup2]
        testRecord = addData(testRecord, "USER_SELECT", FieldType.USER_SELECT, selectUserData)
        testRecord = addData(testRecord, "ORGANIZATION_SELECT", FieldType.ORGANIZATION_SELECT, selectOrgData)
        testRecord = addData(testRecord, "GROUP_SELECT", FieldType.GROUP_SELECT, selectGroupData)
        
        // subTable
        let subtableValue = SubTableValueItem()
        let selectUserDataForSub: [Member] = [self.testUser1, self.testUser2]
        var subtableItem: Dictionary<String, FieldValue> = [:]
        subtableItem = addData(subtableItem, "SINGLE_LINE_TEXT_TABLE", FieldType.SINGLE_LINE_TEXT, "single line text subtable test data")
        subtableItem = addData(subtableItem, "DROP_DOWN_TABLE", FieldType.DROP_DOWN, "sample1")
        subtableItem = addData(subtableItem, "USER_SELECT_TABLE", FieldType.USER_SELECT, selectUserDataForSub)
        subtableValue.setValue(subtableItem)
        let subtableData: [SubTableValueItem] = [subtableValue]
        testRecord = addData(testRecord, "Table", FieldType.SUBTABLE, subtableData)
        
        return testRecord
    }
    
    private func addData(_ recordData: Dictionary<String, FieldValue>, _ code: String, _ type: FieldType, _ value: Any) -> Dictionary<String, FieldValue> {
        
        var recData = recordData
        var field = FieldValue()
        field.setType(type)
        field.setValue(value)
        recData[code] = field
        return recData
    }

    func checkResult(_ fieldType: FieldType, _ fieldValue: Any, _ comarisonValue: Any) {
    
        switch fieldType {
        case .SINGLE_LINE_TEXT:
            fallthrough
        case .MULTI_LINE_TEXT:
            fallthrough
        case .RICH_TEXT:
            fallthrough
        case .DATE:
            fallthrough
        case .TIME:
            fallthrough
        case .DATETIME:
            fallthrough
        case .NUMBER:
            let resultVal = fieldValue as! String
            let expectedVal = comarisonValue as! String
            XCTAssertEqual(resultVal, expectedVal)
            break
        case .SUBTABLE:
            let resultVal = fieldValue as! Array<SubTableValueItem>
            for (_, subVal) in resultVal.enumerated() {
                for (_, val) in (subVal.getValue()?.enumerated())! {
                    XCTAssertNotNil(val.value.getValue())
                }
            }
            break
        case .MULTI_SELECT:
            let resultVal = fieldValue as! Array<String>
            let expectedVal = comarisonValue as! Array<String>
            XCTAssertEqual(resultVal, expectedVal)
            break
        case .USER_SELECT:
            fallthrough
        case .ORGANIZATION_SELECT:
            fallthrough
        case .GROUP_SELECT:
            var resultVal = fieldValue as! Array<Member>
            let expectedVal = comarisonValue as! Array<Member>
            for (i, val) in resultVal.enumerated() {
                XCTAssertTrue(val==expectedVal[i])
            }
            break
        case .FILE:
            var resultVal = fieldValue as! Array<FileModel>
            let expectedVal = comarisonValue as! Array<FileModel>
            for (i, val) in resultVal.enumerated() {
                XCTAssertTrue(val==expectedVal[i])
            }
            break
        default: break
        }
    }
}

extension Member: Equatable {
    static func ==(lhs: Member, rhs: Member) -> Bool {
        return lhs.code == rhs.code && lhs.name == rhs.name
    }
}


extension SubTableValueItem: Equatable {
    static func ==(lhs: SubTableValueItem, rhs: SubTableValueItem) -> Bool {
        return lhs.getID() == rhs.getID() && lhs.getValue() == rhs.getValue()
    }
}
