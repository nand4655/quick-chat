////
////
//// FirestoreServiceTests.swift
//// QuickChatTests
////
//// Created by Nand on 28/04/25
////
//        
//
//import Foundation
//
//import XCTest
//import FirebaseCore
//import FirebaseFirestore
//@testable import QuickChat
//
//import Foundation
//
//struct TestModel: Codable, Identifiable, Equatable {
//    @DocumentID var id: String?
//    let name: String
//    let value: Int
//}
//
//final class FirestoreServiceTests: XCTestCase {
//    var service: FirestoreService!
//    let testCollection = "testCollection"
//    let testDocId = "testDoc"
//    let testSubcollection = "testSubcollection"
//    
//    override class func setUp() {
//        super.setUp()
//        if ProcessInfo.processInfo.environment["unit_tests"] == "true" {
//            print("Setting up Firebase emulator localhost:8080")
//            let settings = Firestore.firestore().settings
//            settings.host = "localhost:8080"
//            settings.isPersistenceEnabled = false
//            settings.isSSLEnabled = false
//            Firestore.firestore().settings = settings
//        }
//    }
//    
//    override func setUpWithError() throws {
//        service = FirestoreService()
//        // Clean up before each test
//        let exp = expectation(description: "Cleanup")
//        Firestore.firestore().collection(testCollection).getDocuments { snapshot, _ in
//            let batch = Firestore.firestore().batch()
//            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
//            batch.commit { _ in exp.fulfill() }
//        }
//        wait(for: [exp], timeout: 5)
//    }
//    
//    func testCreateAndReadDocument() async throws {
//        let model = TestModel(id: testDocId, name: "Test", value: 42)
//        try await service.create(collection: testCollection, id: testDocId, data: model)
//        let fetched: TestModel? = try await service.read(collection: testCollection, id: testDocId)
//        XCTAssertEqual(fetched, model)
//    }
//    
//    func testUpdateDocument() async throws {
//        let model = TestModel(id: testDocId, name: "Test", value: 42)
//        try await service.create(collection: testCollection, id: testDocId, data: model)
//        let updated = TestModel(id: testDocId, name: "Updated", value: 99)
//        try await service.update(collection: testCollection, id: testDocId, data: updated)
//        let fetched: TestModel? = try await service.read(collection: testCollection, id: testDocId)
//        XCTAssertEqual(fetched, updated)
//    }
//    
//    func testDeleteDocument() async throws {
//        let model = TestModel(id: testDocId, name: "Test", value: 42)
//        try await service.create(collection: testCollection, id: testDocId, data: model)
//        try await service.delete(collection: testCollection, id: testDocId)
//        let fetched: TestModel? = try await service.read(collection: testCollection, id: testDocId)
//        XCTAssertNil(fetched)
//    }
//    
//    func testExists() async throws {
//        let model = TestModel(id: testDocId, name: "Test", value: 42)
//        try await service.create(collection: testCollection, id: testDocId, data: model)
//        let exists = try await service.exists(collection: testCollection, id: testDocId)
//        XCTAssertTrue(exists)
//        let notExists = try await service.exists(collection: testCollection, id: "nope")
//        XCTAssertFalse(notExists)
//    }
//    
//    func testList() async throws {
//        let model1 = TestModel(id: "doc1", name: "A", value: 1)
//        let model2 = TestModel(id: "doc2", name: "B", value: 2)
//        try await service.create(collection: testCollection, id: "doc1", data: model1)
//        try await service.create(collection: testCollection, id: "doc2", data: model2)
//        let list: [TestModel] = try await service.list(collection: testCollection)
//        XCTAssertTrue(list.contains(model1))
//        XCTAssertTrue(list.contains(model2))
//    }
//    
//    func testListSubcollection() async throws {
//        let parentId = "parent"
//        let subModel = TestModel(id: "sub1", name: "Sub", value: 10)
//        try await service.create(collection: testCollection, id: parentId, data: TestModel(id: parentId, name: "P", value: 0))
//        try await service.addToSubcollection(collection: testCollection, documentId: parentId, subcollection: testSubcollection, data: subModel)
//        let list: [TestModel] = try await service.listSubcollection(collection: testCollection, documentId: parentId, subcollection: testSubcollection)
//        XCTAssertTrue(list.contains(where: { $0.name == "Sub" }))
//    }
//    
//    func testAddToSubcollection() async throws {
//        let parentId = "parent"
//        let subModel = TestModel(id: nil, name: "Sub", value: 10)
//        try await service.create(collection: testCollection, id: parentId, data: TestModel(id: parentId, name: "P", value: 0))
//        try await service.addToSubcollection(collection: testCollection, documentId: parentId, subcollection: testSubcollection, data: subModel)
//        let list: [TestModel] = try await service.listSubcollection(collection: testCollection, documentId: parentId, subcollection: testSubcollection)
//        XCTAssertTrue(list.contains(where: { $0.name == "Sub" }))
//    }
//    
//    func testUpdateSubcollectionDocumentField() async throws {
//        let parentId = "parent"
//        let subId = "sub1"
//        let subModel = TestModel(id: subId, name: "Sub", value: 10)
//        try await service.create(collection: testCollection, id: parentId, data: TestModel(id: parentId, name: "P", value: 0))
//        let db = Firestore.firestore()
//        try await db.collection(testCollection).document(parentId).collection(testSubcollection).document(subId).setData(from: subModel)
//        try await service.updateSubcollectionDocumentField(
//            collection: testCollection,
//            documentId: parentId,
//            subcollection: testSubcollection,
//            subdocumentId: subId,
//            data: ["name": "UpdatedSub"]
//        )
//        let list: [TestModel] = try await service.listSubcollection(collection: testCollection, documentId: parentId, subcollection: testSubcollection)
//        XCTAssertTrue(list.contains(where: { $0.name == "UpdatedSub" }))
//    }
//    
//    func testUpdateFields() async throws {
//        let model = TestModel(id: testDocId, name: "Test", value: 42)
//        try await service.create(collection: testCollection, id: testDocId, data: model)
//        try await service.updateFields(collection: testCollection, id: testDocId, data: ["name": "Changed"])
//        let fetched: TestModel? = try await service.read(collection: testCollection, id: testDocId)
//        XCTAssertEqual(fetched?.name, "Changed")
//    }
//}
