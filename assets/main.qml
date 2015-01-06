/*
 * Copyright (c) 2011-2014 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.4
import bb.cascades.pickers 1.0
import bb.system 1.2

Page {
    id: page
    property bool fileloaded
    property string fileurl
    property int filesize
    property string imageurl
    titleBar: TitleBar {
        title: qsTr("Anonymous Imgur Uploader") + Retranslate.onLanguageChanged
    }
    attachedObjects: [
        FilePicker {
            property string selectedFile
            id: filepicker
            type: FileType.Picture
            onFileSelected: {
                reselectbutton.enabled = true
                fileloaded = true
                fileurl = ""
                imageurl = ""
                progress.resetToValue()
                progress.resetValue()
                selectedFile = selectedFiles[0]
                filesize = uploader.fileSize(selectedFile)
                imgview.imageSource = "file://" + selectedFile
            }
        },
        SystemToast {
            id: toast
            body: qsTr("Uploaded!") + Retranslate.onLanguageChanged
        }
    ]
    actions: [
        ActionItem {
            id: bigbutton
            title: (fileloaded == true ? qsTr("Upload Image") + Retranslate.onLanguageChanged : qsTr("Load Image") + Retranslate.onLanguageChanged)
            imageSource: (fileloaded == true ? "asset:///images/ic_browser.png" : "asset:///images/ic_doctype_picture.png")
            onTriggered: {
                if (fileloaded == true){
                    reselectbutton.enabled = false
                    bigbutton.enabled = false
                    uploader.uploadFile(filepicker.selectedFile.toString())
                }
                else {
                    filepicker.open()
                }
            }
            ActionBar.placement: ActionBarPlacement.Signature
        },
        ActionItem {
            title: qsTr("Copy URL") + Retranslate.onLanguageChanged
            enabled: (fileurl == "" ? false : true)
            imageSource: "asset:///images/ic_copy_link.png"
            onTriggered: {
                Clipboard.copyToClipboard(fileurl)
            }
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        ActionItem {
            title: qsTr("Copy Image URL") + Retranslate.onLanguageChanged
            enabled: (imageurl == "" ? false : true)
            imageSource: "asset:///images/ic_copy_link.png"
            onTriggered: {
                Clipboard.copyToClipboard(imageurl)
            }
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        ActionItem {
            id: reselectbutton
            title: qsTr("Reselect File") + Retranslate.onLanguageChanged
            enabled: false
            imageSource: "asset:///images/ic_doctype_picture.png"
            onTriggered: {
                fileloaded = false
                filepicker.open()
            }
            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    Container {
        Label {
            text: qsTr("Selected file: %1").arg(filepicker.selectedFile) + Retranslate.onLanguageChanged
        }
        Label {
            text: qsTr("File size: %1 bytes").arg(filesize.toString()) + Retranslate.onLanguageChanged
        }
        Label {
            text: qsTr("URL: %1").arg(fileurl) + Retranslate.onLanguageChanged
            textFormat: TextFormat.Auto
            content.flags: TextContentFlag.ActiveText
        }
        Label {
            text: qsTr("Image URL: %1").arg(imageurl) + Retranslate.onLanguageChanged
            textFormat: TextFormat.Auto
            content.flags: TextContentFlag.ActiveText
        }
        Container {
            topPadding: 10.0
            bottomPadding: 10.0
            ProgressIndicator {
                id: progress
            }
        }
        Label {
            id: percentlabel
            horizontalAlignment: HorizontalAlignment.Center
            text: qsTr("%1% complete").arg((progress.value/progress.toValue * 100.0).toFixed(1).toString()) + Retranslate.onLanguageChanged
        }
        Divider {
        
        }
        ScrollView {
            horizontalAlignment: HorizontalAlignment.Center
            scrollViewProperties.initialScalingMethod: ScalingMethod.AspectFit
            scrollViewProperties.pinchToZoomEnabled: false
            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.None
            scrollViewProperties.scrollMode: ScrollMode.None
            ImageView {
                id: imgview
                scalingMethod: ScalingMethod.AspectFit
            }
        }
    }
    onCreationCompleted: {
        uploader.uploadDone.connect(function(result){
            bigbutton.enabled = true
            fileurl = result["imgur_page"]
            imageurl = result["original"]
            toast.body = qsTr("Uploaded!") + Retranslate.onLanguageChanged
            toast.show()
            fileloaded = false
        })
        uploader.uploadError.connect(function(){
            toast.body = qsTr("Error!") + Retranslate.onLanguageChanged
            toast.show()
        })
        uploader.uploadProgress.connect(function(send, to) {
            progress.toValue = to;
            progress.value = send;
        })
    }
}
