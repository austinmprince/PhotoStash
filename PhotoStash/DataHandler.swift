
import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import Photos


var ref: DatabaseReference!
var handle:DatabaseHandle?
var images:[UIImage] = []


struct DataHandler {
    
    static func getImage(path: String) -> UIImage{
        guard let url = URL(string: path) else { return UIImage(named: "no-photo-template")! }
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch {
            return UIImage(named: "no-photo-template")!
        }
    }
    
    static func getAlbumPics(path: String) {
        print("Getting albums pics")
        var urls:[String] = []
        ref = Database.database().reference()
        
        ref.child("AlbumPhotos").child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            let albList = snapshot.value as? NSDictionary
            
            print("image url: " + "(\(albList)")
            
            let albArray = albList?.allValues as? [String]
            
            //Putting image url into an array
            for element in albArray!  {
                print("Image URL: \(element)")
                let types = type(of: element)
                print("Image type: \(types)")
                urls.append(element)
            }
        })
        print ("Values in array: \(urls.count)")
        //return albArray
    }
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        print("\(size)")
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func uploadSingleImage(image: UIImage, album: String) {
        ref = Database.database().reference()
        let storageRef = Storage.storage().reference()
        var downloadURL = ""
        let imageName = NSUUID.init()
        let compressH = image.size.height / 10
        let compressW = image.size.width / 10
        let compressedNail = resizeImage(image: image, targetSize: CGSize(width: compressW, height: compressH))
        let uploadFull = UIImageJPEGRepresentation(image, 0.8)
        let uploadNail = UIImageJPEGRepresentation(compressedNail, 0.8)
        var picRef = storageRef.child("Pictures").child("\(imageName).jpg")
        let arrayOfImages: [Bool: Data? ] = [true: uploadFull, false: uploadNail]
        
        DispatchQueue.global(qos: .background).async {
            for (key, element) in arrayOfImages {
                if key == true {
                    picRef = storageRef.child("Pictures").child("\(imageName).jpg")
                }
                else {
                    picRef = storageRef.child("Nails").child("\(imageName).jpg")
                }
                let uploadingTask = picRef.putData(element!, metadata: nil) {
                    (metadata, error) in
                    print("uploading in single image")
                    guard
                        let metadata = metadata
                        else {
                            // Uh-oh, an error occurred!
                            return
                    }
                    if error != nil {
                        print(error as Any)
                    }
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    downloadURL = (metadata.downloadURL()? .absoluteString)!
                    //                    let album = ref.child("AlbumPhotos").child(album).child(String(describing: imageName))
                    let albumRef = ref.child("AlbumPhotos").child(album)
                    let coverRef = ref.child("Album").child(album)
                    let numElements = 0
                    coverRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        let values = snapshot.value as? NSDictionary
                        if let numPics = values!["numPhotos"] {
                            if numPics as? Int == 0 {
                                if key == true {
                                    coverRef.child("coverPhoto").setValue(downloadURL)
                                }
                            }
                        }
                        if let coverPhoto = values!["coverPhoto"] {
                            
                        }
                        else {
                            // want full size image for album photo
                            if key == true {
                                coverRef.child("coverPhoto").setValue(downloadURL)
                            }
                        }
                        
                    })
                    if key == true {
                        albumRef.child(String(describing: imageName)).child("full").setValue(downloadURL)
                        
                        print("downloadURL = " + downloadURL)
                    }
                    else {
                        albumRef.child(String(describing: imageName)).child("nail").setValue(downloadURL)
                    }
                }
            }
        }
    }
    
    static func setProfilePic(image: UIImage, user: String) {
        ref = Database.database().reference()
        let storageRef = Storage.storage().reference()
        var downloadURL = ""
        let imageName = NSUUID.init()
        let uploadFull = UIImageJPEGRepresentation(image, 0.8)
        var picRef = storageRef.child("ProfilePics").child("\(imageName).jpg")
        DispatchQueue.global().async {
                picRef = storageRef.child("ProfilePics").child("\(imageName).jpg")
                let uploadingTask = picRef.putData(uploadFull!, metadata: nil) {
                    (metadata, error) in
                    print("uploading in single image")
                    guard
                        let metadata = metadata
                        else {
                            // Uh-oh, an error occurred!
                            return
                        }
                    if error != nil {
                        print(error as Any)
                    }
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    downloadURL = (metadata.downloadURL()? .absoluteString)!
                    ref.child("Users").child(user).child("profPic").setValue(downloadURL)
            }
        }
    }
    static func updateDates(album: String, startDate: Date?, endDate: Date?, user: String, autoUpload: Bool) {
        ref = Database.database().reference()
        let formatter = DateFormatter()
        ref.child("Album").child(album).child("Members").child(user).setValue(autoUpload)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if let startString = startDate {
            let formattedStart = formatter.string(from: startString)
            print(formattedStart)
            ref.child("Album").child(album).child("startDate").setValue(formattedStart)
        }
        if let endString = endDate {
            let formattedEnd = formatter.string(from: endString)
            print(formattedEnd)
            ref.child("Album").child(album).child("endDate").setValue(formattedEnd)
        }
        
    }
    
    
    static func uploadImageArray(array: [UIImage], album: String) {
        for image in array {
            uploadSingleImage(image: image, album: album)
        }
        
        
    }
    static func fetchPhotosInRange(startString:String, endString:String, album: String, user: String) {
        print("getting photos")
        print(album)
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let startDate = formatter.date(from: startString) as! NSDate
                let endCompare = formatter.date(from: endString)
                let endDate = formatter.date(from: endString) as! NSDate
                if date > endCompare! {
                   
                    let imgManager = PHImageManager.default()
                    ref = Database.database().reference()
                    ref.child("Album").child(album).child("Members").child(user).setValue(false)
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = false
                    requestOptions.isNetworkAccessAllowed = true
                    
                    let storageRef = Storage.storage().reference()
                    
                    // Fetch the images between the start and end date
                    let fetchOptions = PHFetchOptions()
                    
                    fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@", startDate, endDate)
                    
                    images = []
                    
                    
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                    // If the fetch result isn't empty,
                    // proceed with the image request
                    print(fetchResult.count)
                    if fetchResult.count > 0 {
                        print("made it here")
                        // Perform the image request
                        DispatchQueue.global(qos: .background).async {
                            for index in 0  ..< fetchResult.count  {
                                let asset = fetchResult.object(at: index)
                                imgManager.requestImageData(for: asset, options: requestOptions, resultHandler: { (imageData: Data?, dataUTI: String?, orientation: UIImageOrientation, info: [AnyHashable : Any]?) -> Void in
                                    if let imageData = imageData {
                                        if let image = UIImage(data: imageData) {
                                            DataHandler.uploadSingleImage(image: image, album: album)
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    static func sendInvites(people:[String], album:String, inviteUser:String) {
        ref = Database.database().reference()
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                for person in people {
                    let userRef = ref.child("Users")
                    let personRef = userRef.child(person)
                    let inviteRef = personRef.child("Invites")
                    let albumRef = inviteRef.child(album)
                    albumRef.setValue(inviteUser)
                }
            }
        }
        
    }
    
    static func acceptInvite(user: String, albums: [String:Bool]) {
        ref = Database.database().reference()
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                for (key, value) in albums {
                    if value == true {
                        ref.child("Album").child(key).child("Members").child(user).setValue(false)
                        ref.child("Users").child(user).child("albums").child(key).setValue(true)
                    }
                    ref.child("Users").child(user).child("Invites").child(key).removeValue()
                }
            }
        }
    }
    
    static func createAlbum(creator:String, albumTitle: String, autoUpload: Bool, startDate: Date?, endDate: Date?) {
        ref = Database.database().reference()
        ref.child("Album").child(albumTitle).child(creator).setValue(autoUpload)
        ref.child("Album").child(albumTitle).child("Members").child(creator).setValue(autoUpload)
        ref.child("Users").child(creator).child("albums").child(albumTitle).setValue(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if autoUpload {
            if let startString = startDate {
                let formattedStart = formatter.string(from: startString)
                print(formattedStart)
                ref.child("Album").child(albumTitle).child("startDate").setValue(formattedStart)
            }
            if let endString = endDate {
                let formattedEnd = formatter.string(from: endString)
                print(formattedEnd)
                ref.child("Album").child(albumTitle).child("endDate").setValue(formattedEnd)
            }
        }
        
    }
    
    //    static func setAlbumPhoto(album: String, coverPhotoURL: String) {
    //        ref = Database.database().reference()
    //        var count = 0
    //        ref.child("AlbumPhotos").child(album).observeSingleEvent(of: .value, with: {(snapshot) in
    //            count = count + 1
    //        })
    //        if count > 0 {
    //            ref.child("AlbumPhotos").child(album).child("coverPhoto").setValue(coverPhotoURL)
    //        }
    //
    //    }
    
    static func removePhotoWID(id: String, album:String) {
        ref = Database.database().reference()
        
        DispatchQueue.global().async {
            let picRef = ref.child("AlbumPhotos").child(album).child(id)
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                picRef.removeValue()
            })
        }
    }
    
    static func registerUser(user: User) {
        ref = Database.database().reference()
        if user.getFirstName() == "" || user.getLastName() == ""  {
            return
        }
        let username = user.getFirstName() + " " + user.getLastName()
        let userRef = ref.child("Users").child(user.getUID())
        userRef.child("username").setValue(username)
        userRef.child("email").setValue(user.getEmail())
        if let profPic = user.profPic {
            DataHandler.setProfilePic(image: profPic, user: user.getUID())
        }
        
    
    }
    
    static func setAutoUpload(album: String, userId: String, autoUp: Bool) {
        ref = Database.database().reference()
        ref.child("Album").child(album).child("Members").child(userId).setValue(autoUp)
    }
    
    static func leaveAlbum(user: String, album: String) {
        ref = Database.database().reference()
        ref.child("Users").child(user).child("albums").child(album).removeValue()
        ref.child("Album").child(album).child("Members").child(user).removeValue()
    }
    
    
    
    
}
