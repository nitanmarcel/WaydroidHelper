import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components.Popups 1.3

Page {
    id: aboutPage    
    header: PageHeader {
        id: header
        title: i18n.tr("Install Waydroid")
        opacity: 1
        trailingActionBar {
            actions: [
            Action {
                iconName: "google-plus-symbolic"
                text: i18n.tr("GAPPS")
                onTriggered: PopupUtils.open(gapps)
                
            }
        ]
        }
    }

    MainView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Component.onCompleted: PopupUtils.open(dialogInstall)

        ActivityIndicator {
            id: activity
            anchors.top: parent.top
            anchors.topMargin: parent.height / 15
            anchors.horizontalCenter: parent.horizontalCenter
        }
            
        Label {
            id: content
            anchors.top: (activity.running == true) ? activity.bottom : parent.top
            anchors.topMargin:(activity.running == true) ? parent.height / 15 : parent.height / 25
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            width: parent.width / 1.5
            text: i18n.tr("By pressing 'start' the installation will, well... start. The installer will let you know what it is doing at the moment. Be patient! The installation may take a while. Do not close the app during the installation! Once Waydroid is installed, your device will restart automatically. I reccomend to disable screen suspension in the settings to keep the screen always on without touching it.")
            font.pointSize: 25
            wrapMode: Text.Wrap
        }
        Button {
            id: startButton
            anchors.top: content.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "green"
            text: i18n.tr("Start")
            onClicked: {
                startButton.visible = false
                startButtonFake.visible = true
                activity.running = true
                PopupUtils.open(passwordPrompt)
            }
        }
        Button {
            id: startButtonFake
            visible: false
            anchors.top: content.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "gray"
            text: i18n.tr("Running")
            onClicked: console.log("Installer is running")
        }
    }

    property var gAPPS: false
    Component {
        id: dialogInstall
        Dialog {
            id: dialogueInstall
            title: "Disclaimer!"
            Label {
                text: i18n.tr("You are about to use an experimental Waydroid installer! <br> Supported devices (✔️ = tested): <br> * VollaPhone ✔️ (X) <br> * Redmi Note 7 (Pro) <br> * Redmi Note (9 Pro/9 Pro Max) <br> * Fairphone 3(+) <br> * Pixel (3a/XL/2 XL) <br> * MI A2 (wifi does not work with GAPPS) <br> * Poco F1 <br> * SHIFT6mq <br> These devices have partial support: <br> * Pixel 3a XL (no video playback) <br> * Pinephone (unstable) <br> * Redmi Note 9 (no external storage) <br> There is absolutely no warranty for this to work! Do not use this installer if you dont want to risk to brick your device (,which is highly unlikely though)!")
                wrapMode: Text.Wrap
            }

            Button {
                text: i18n.tr ("I understand the risk")
                color: "red"
                onClicked: PopupUtils.close(dialogueInstall)
            }
            Button {
                text: i18n.tr("Cancel")
                color: "green"
                onClicked: {
                    PopupUtils.close(dialogueInstall)
                    pageStack.pop()
                
                }

            }

        }
    }

    Component {
        id: passwordPrompt
        Dialog {
            id: passPrompt
            title: "Password"
            Label {
                text: i18n.tr("Enter your password:")
                wrapMode: Text.Wrap
            }
            TextField {
                id: password
                placeholderText: "password"
                echoMode: TextInput.Password
            }

            Button {
                text: i18n.tr("Ok")
                color: "green"
                onClicked: {
                    PopupUtils.close(passPrompt)
                    python.call('installer.install', [password.text, gAPPS], function(returnValue) {
                        console.log('test was executed');
                    })
                    
                
                }

            }

        }
    }
    
    Component {
        id: gapps
        Dialog {
            id: gappsPromt
            title: "Google Apps"
            Label {
                text: i18n.tr("You can install a special version of Waydroid that comes with google apps. (I personally do not recommend this as it will result in worse privacy.)")
                wrapMode: Text.Wrap
            }

            Button {
                text: i18n.tr("Enable GAPPS")
                color: "red"
                onClicked: {
                    gAPPS = true
                    PopupUtils.close(gappsPromt)
                                       
                
                }

            }
            Button {
                text: i18n.tr("Cancel")
                color: "green"
                onClicked: {
                    PopupUtils.close(gappsPromt)
                    
                
                }

            }
        }
    }
    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importNames('installer', ['installer'], function() {
                console.log('installer module imported');

            });

            python.setHandler('whatState',
                function (state) {
                    content.text = state
                })

        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
