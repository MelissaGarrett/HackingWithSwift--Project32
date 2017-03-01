//
//  ViewController.swift
//  Project32
//
//  Created by Melissa  Garrett on 2/28/17.
//  Copyright © 2017 MelissaGarrett. All rights reserved.
//

import SafariServices
import UIKit
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController {
    
    var projects = [[String]]()
    
    var favorites = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, FileManager, storyboards"])
        projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL"])
        projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"])
        projects.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange"])
        projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        projects.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController"])
        projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerated(), count, index(of:), property observers, range operators."])
        
        // Load list of favorited web pages
        let defaults = UserDefaults.standard
        
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
        
        // So users can mark table cells(projects) as favorited
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        
        cell.textLabel?.attributedText = makeAttributedString(title: project[0], subtitle: project[1])
        
        // To show checkmark if the cell is in the favorited array
        if favorites.contains(indexPath.row) {
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    // Reconfigure the cell size based on its text
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // To format the table cell's text using NSAttributedString
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline), NSForegroundColorAttributeName: UIColor.purple]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes) // 'mutable' so we can append subtitleString
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }

    // To show the tutorial URL corresponding to the one tapped in the table
    func showTutorial(_ which: Int) {
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            
            present(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    // To include the delete(-) or insert(+) icon on each cell
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if favorites.contains(indexPath.row) {
            return .delete
        } else {
            return .insert
        }
    }
    
    // Check if user is trying to delete or insert their favorited project
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        } else {
            if let index = favorites.index(of: indexPath.row) {
                favorites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // Add favorited project to Core Spotlight (by tapping the '+')
    func index(item: Int) {
        let project = projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project[0]
        attributeSet.contentDescription = project[1]
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    // Remove favorited project from Core Spotlight (by tapping the '-', then Delete)
    func deindex(item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
}

