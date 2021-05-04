# 내손은 금손 (Core ML)

| 팀원     | 사용 언어                                                    |
| -------- | ------------------------------------------------------------ |
| Joons 🏄‍♂️ | <img width="200" alt="Swift" src="https://user-images.githubusercontent.com/40102795/114259983-f7a4f480-9a0c-11eb-8f57-2da635febfd9.png"> |

- Create ML을 통한 학습 모델 : DrawImageClassifier.mlmodel
- Keras를 통한 학습 모델 : ShapDetectorKeras.mlmodel

- UIBezierPath를 사용하여 CanvasView(UIView)에 그림을 그릴 수 있게 구현
- TDD를 활용하여 최대한 Testable한 코드를 작성하고자 노력 
  - Test에 대한 커밋은 실패하는 테스트 케이스 작성하여 커밋, 성공하게 만들고, 리팩토링 까지 하여 커밋 이런식으로 커밋을 진행
- Touch Event를 함께 활용하여 터치를 시작하고, 끝나는 시점에 하나의 Path가 완성되어 paths라는 배열에 담아두는 방식으로 구현



## Tests

```swift
CanvasViewTests
	- testView_whenErase_allPathsAreClear()
 	- testView_whenexportImageFromView_imageIsNotNil()

ViewControllerTests
	- testController_whenStartApp_labelsAreHidden()
	- testController_whenTappedShowResultButton_labelsAreNotHidden()
	- testController_whenTappedClearButton_labelsAreHidden
```





## 고민하고 있어요!

- ✅ CreateML시 Maximum Iterations를 아무리 크게 줘도 10회만 학습하는 것 같다. 

  - Training Accuracy가 100%가 되면 Maximum을 채우지 않고 종료한다. (학습이 끝나면 종료!)

- ❌ test code를 작성하는 과정에서 Label들을 테스트하는데 private 접근제한자로 선언하였는데. 

  - ```swift
    private let looksLikeLabel = ResultLabel(font: UIFont.preferredFont(forTextStyle: .title1))
    ```

    기존에 이런식으로 선언한 것을

    ```swift
    private(set) var looksLikeLabel = ResultLabel(font: UIFont.preferredFont(forTextStyle: .title1))
    ```

    이렇게 변경하여 테스트 진행하였습니다 이런 방식이 맞는건지?

- ✅ private 접근제한자가 붙은 메서드에 대한 test코드를 만드는 방법?

  - Private 메서드의 테스트에 대한 여러 글들을 읽어보았다. private로 선언하였으면 그 의도가 있을것이므로 test를 굳이 진행하지 않아도 괜찮다는 의견도 있지만, 어떤 블로그 글에서는 WWDC 17 Engineering of Testability 세션에서 보았던 의존성 분리를 통해서 해결하는 방법도 확인할 수 있었다.  
  
- ❌ 그림 예측을 할 때 별모양은 잘 인식을 하지 못하는 것 같다. (계속 Triangle이라고함 ㅠㅠ)



## Refactoring

- 기존에 `testController_whenTappedClearButton_canvasViewIsClear()` 테스트를 진행하였다. Clear 버튼을 탭할시 canvasView의 모든 그림들이 지워지는지에 대한 테스트를 진행한 것인데, 이는 이미 CanvasView 테스트에서 `clear()` 에 대한 테스트를 한 것이다. 그렇기 때문에 테스트가 중복된다고 생각하여 삭제해주었다.

- [Bug Fix] 지우기를 누르고 다시 그림을 그리려고 할 때 index out of range 에러 발생.

  ```swift
  (lldb) po numberOfPath
  4
  ```

  간단했다. numberOfPath를 초기화해주지 않았다.

  ```swift
  func erase() {
    paths.removeAll()
    numberOfPath = 0
    setNeedsDisplay()
  }
  ```

