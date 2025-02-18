//
//  CreateViewModel.swift
//  BibliographicGuide
//
//  Created by Alexander on 18.04.23.
//

import Combine
import Foundation

final class CreateRecordViewModel: ObservableObject {
    
    var userId = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
    
    @Published var recordRepository = globalRecordRepository
    
    @Published var keywordRepository = globalKeywordRepository
    @Published var keywords: [Keyword] = []
    @Published var selectedKeywordsId: [String] = []
    @Published var selectedKeywords: [Keyword] = []
    @Published var searchKeywords: [Keyword] = []
    
    @Published var userInformationRepository = globalUserInformationRepository
    @Published var usersInformation: [UserInformation] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(){
        keywordRepository.$keywords
            .assign(to: \.keywords, on: self)
            .store(in: &cancellables)
        
        userInformationRepository.$usersInformation
            .assign(to: \.usersInformation, on: self)
            .store(in: &cancellables)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main){
            (_) in
            let userId = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
            self.userId = userId
        }
    }
    
    func fetchKeywordsSearch(SearchString: String){
        if(SearchString != ""){
            searchKeywords = keywords.filter{ $0.name.lowercased().contains(SearchString.lowercased())
            }
        }
        else{
            searchKeywords = keywords
        }
    }
    
    func getСurrentUserInformation() -> UserInformation{
        let userName = usersInformation.filter { (item) -> Bool in
            item.id == userId
        }
        return userName.first ?? UserInformation(role: "", userName: "", updatingImage: 0, blockingChat: true, blockingAccount: true, reasonBlockingAccount: "", language: "")
    }
    
    func addRecord(_ record: Record, imageTitle: Data, isImageTitle: Bool, completion: @escaping (Bool, String)->Void){
        var newRecord = record
        newRecord.idUser = userId
        if(isImageTitle){
            newRecord.updatingImage = 1
        }
        recordRepository.addRecord(record: newRecord, imageTitle: imageTitle, isImageTitle: isImageTitle){ (verified, status) in
            if !verified {
                completion(false, "Ошибка при запросе создания записи.")
            }
            else{
                self.selectedKeywordsId.removeAll()
                globalKeywordRepository.selectedKeywordsSearch.removeAll()
                globalKeywordRepository.sortingNameKeywords()
                completion(true, status)
            }
        }
    }
    
    func sortingKeyword(_ keyword: Keyword){
        if(selectedKeywordsId.contains(keyword.id ?? "")){
            selectedKeywordsId.remove(at: selectedKeywordsId.firstIndex(of: keyword.id ?? "") ?? 999999)
        }
        else{
            selectedKeywordsId.append(keyword.id ?? "")
        }
        globalKeywordRepository.selectedKeywordsSearch = selectedKeywordsId
        globalKeywordRepository.sortingKeywords()
    }
    
    func keywordsIdToKeywords(){
        selectedKeywords.removeAll()
        for keyword in selectedKeywordsId {
            selectedKeywords.append(keywords.first(where: { $0.id == keyword }) ?? Keyword(name: ""))
        }
    }
}
