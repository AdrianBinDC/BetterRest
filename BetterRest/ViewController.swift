//
//  ViewController.swift
//  BetterRest
//
//  Created by Adrian Bolinger on 7/7/19.
//  Copyright © 2019 Adrian Bolinger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var mainStackView: UIStackView!
    
    var wakeUpTitle: UILabel!
    var wakeUpTime: UIDatePicker!
    
    var sleepStackView: UIStackView!
    var sleepTitle: UILabel!
    var sleepAmountTime: UIStepper!
    var sleepAmountLabel: UILabel!
    
    var coffeeStackView: UIStackView!
    var coffeeTitle: UILabel!
    var coffeeAmountStepper: UIStepper!
    var coffeeAmountLabel: UILabel!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        wakeUpTitle = UILabel()
        wakeUpTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        wakeUpTitle.numberOfLines = 0
        wakeUpTitle.text = "When do you want to wake up?"
        mainStackView.addArrangedSubview(wakeUpTitle)
        
        wakeUpTime = UIDatePicker()
        wakeUpTime.datePickerMode = .time
        wakeUpTime.minuteInterval = 15
        mainStackView.addArrangedSubview(wakeUpTime)
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = 8
        components.minute = 0
        wakeUpTime.date = Calendar.current.date(from: components) ?? Date()
        
        sleepTitle = UILabel()
        sleepTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        sleepTitle.numberOfLines = 0
        sleepTitle.text = "What's the miniumum amount of sleep you want?"
        mainStackView.addArrangedSubview(sleepTitle)
        
        sleepAmountTime = UIStepper()
        sleepAmountTime.addTarget(self, action: #selector(sleepAmountChanged), for: .valueChanged)
        sleepAmountTime.stepValue = 0.25
        sleepAmountTime.value = 8
        sleepAmountTime.minimumValue = 4
        sleepAmountTime.maximumValue = 12
        
        sleepAmountLabel = UILabel()
        sleepAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        sleepStackView = UIStackView()
        sleepStackView.spacing = 20
        sleepStackView.addArrangedSubview(sleepAmountTime)
        sleepStackView.addArrangedSubview(sleepAmountLabel)
        mainStackView.addArrangedSubview(sleepStackView)
        
        coffeeTitle = UILabel()
        coffeeTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        coffeeTitle.numberOfLines = 0
        coffeeTitle.text = "How much coffee do you drink each day?"
        mainStackView.addArrangedSubview(coffeeTitle)
        
        coffeeAmountStepper = UIStepper()
        coffeeAmountStepper.addTarget(self, action: #selector(coffeeAmountChanged(sender:)), for: .valueChanged)
        coffeeAmountStepper.minimumValue = 1
        coffeeAmountStepper.maximumValue = 20
        coffeeAmountStepper.value = 1
        
        coffeeAmountLabel = UILabel()
        coffeeAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        coffeeAmountLabel.text = "1 cup"
        
        coffeeStackView = UIStackView()
        coffeeStackView.spacing = 20
        coffeeStackView.addArrangedSubview(coffeeAmountStepper)
        coffeeStackView.addArrangedSubview(coffeeAmountLabel)
        mainStackView.addArrangedSubview(coffeeStackView)
        
        mainStackView.setCustomSpacing(10, after: sleepTitle)
        mainStackView.setCustomSpacing(20, after: sleepStackView)
        mainStackView.setCustomSpacing(10, after: coffeeTitle)
        
        sleepAmountChanged()
        coffeeAmountChanged(sender: coffeeAmountStepper)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Better Rest"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calculate",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(calculateBedtime))
    }

    @objc func sleepAmountChanged() {
        // %g rounds
        sleepAmountLabel.text = String(format: "%g hours", sleepAmountTime.value)
    }
    
    @objc func coffeeAmountChanged(sender: UIStepper) {
        if sender.value == 1 {
            coffeeAmountLabel.text = "1 cup"
        } else {
            coffeeAmountLabel.text = "\(Int(sender.value)) cups"
        }
    }
    
    @objc func calculateBedtime() {
        let model = SleepCalculatormmlmodel()
        
        let title: String
        let message: String
        
        do {
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime.date)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(coffee: coffeeAmountStepper.value,
                                                  estimatedSleep: sleepAmountTime.value,
                                                  wake: Double(hour + minute))
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            let wakeDate = wakeUpTime.date - prediction.actualSleep
            message = formatter.string(from: wakeDate)
            
            title = "Your ideal bedtime is..."
        } catch  {
            title = "Error"
            message = "Sorry, there was a problem calculating your bedtime."
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true) {
            // maybe add something later
        }
    }
}

