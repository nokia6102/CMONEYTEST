
let AQI_URL = "https://raw.githubusercontent.com/cmmobile/NasaDataSet/main/apod.json".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)



struct ExCmoney : Codable {
    
    let descriptionField : String?
    let copyright : String?
    let title : String?
    let url : String?
    let apodSite : String?
    let date : String?
    let mediaType : String?
    let hdurl : String?
    
    enum CodingKeys: String, CodingKey {
        case descriptionField = "description"
        case copyright = "copyright"
        case title = "title"
        case url = "url"
        case apodSite = "apod_site"
        case date = "date"
        case mediaType = "media_type"
        case hdurl = "hdurl"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        copyright = try values.decodeIfPresent(String.self, forKey: .copyright)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        apodSite = try values.decodeIfPresent(String.self, forKey: .apodSite)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        mediaType = try values.decodeIfPresent(String.self, forKey: .mediaType)
        hdurl = try values.decodeIfPresent(String.self, forKey: .hdurl)
    }
    
}
