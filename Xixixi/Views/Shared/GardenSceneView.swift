import SwiftUI

// MARK: - Triangle helper shape
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

// MARK: - Cat behaviour
enum CatState: CaseIterable {
    case sleeping, sitting, playing, wandering
}

// MARK: - GardenSceneView
/// 全动态花园场景：以水彩插画为背景，叠加小猫/蝴蝶/青蛙动画
struct GardenSceneView: View {
    var onCatTap: () -> Void

    // ── Cat ──
    @State private var catState: CatState = .sitting
    @State private var catX: CGFloat = 0.415   // 对应原图猫咪位置
    @State private var catY: CGFloat = 0.640
    @State private var catFaceRight: Bool = false
    @State private var catBounce: CGFloat = 0
    @State private var catHeartVisible: Bool = false

    // ── Butterflies ──
    // 蝴蝶1：在画面中央上方飞
    @State private var bf1Angle: Double = 0
    // 蝴蝶2：在右侧路边飞
    @State private var bf2Angle: Double = 180
    @State private var wingToggle: Bool = false

    // ── Frog ── (左侧水池睡莲上)
    @State private var frogJumpY: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .topLeading) {

                // ── 背景：水彩插画 ──
                Image("garden_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()

                // ── 青蛙（水池睡莲上，约图中左 19%，下 62%）──
                frogView(w: w, h: h)

                // ── 蝴蝶1：画面中央区域（中央小蝴蝶）──
                butterflyView(w: w, h: h,
                              centerX: 0.42, centerY: 0.46,
                              radiusX: 0.07, radiusY: 0.04,
                              angle: bf1Angle,
                              color: Color(red: 0.72, green: 0.50, blue: 0.95))

                // ── 蝴蝶2：右侧路边（右下角橙色蝴蝶）──
                butterflyView(w: w, h: h,
                              centerX: 0.82, centerY: 0.68,
                              radiusX: 0.055, radiusY: 0.030,
                              angle: bf2Angle,
                              color: Color(red: 1.0, green: 0.68, blue: 0.10))

                // ── 小猫（坐在水池旁石头上）──
                catView(w: w, h: h)
            }
            .clipped()
            .onAppear { startAnimations(w: w, h: h) }
        }
    }

    // MARK: - Frog
    @ViewBuilder
    private func frogView(w: CGFloat, h: CGFloat) -> some View {
        // 青蛙在水池左侧睡莲上，原图约 (19%, 63%)
        let fs = w * 0.034
        ZStack {
            // 身体
            Ellipse()
                .fill(Color(red: 0.30, green: 0.68, blue: 0.32))
                .frame(width: fs, height: fs * 0.72)
            // 肚皮
            Ellipse()
                .fill(Color(red: 0.72, green: 0.90, blue: 0.55).opacity(0.65))
                .frame(width: fs * 0.55, height: fs * 0.40)
                .offset(y: fs * 0.08)
            // 眼睛鼓包
            Circle()
                .fill(Color(red: 0.26, green: 0.60, blue: 0.28))
                .frame(width: fs * 0.35)
                .offset(x: -fs * 0.18, y: -fs * 0.28)
            Circle()
                .fill(Color(red: 0.26, green: 0.60, blue: 0.28))
                .frame(width: fs * 0.35)
                .offset(x:  fs * 0.18, y: -fs * 0.28)
            // 瞳孔
            Circle().fill(Color.black.opacity(0.85))
                .frame(width: fs * 0.15)
                .offset(x: -fs * 0.18, y: -fs * 0.28)
            Circle().fill(Color.black.opacity(0.85))
                .frame(width: fs * 0.15)
                .offset(x:  fs * 0.18, y: -fs * 0.28)
            // 微笑
            Path { p in
                p.move(to: CGPoint(x: -fs * 0.12, y: fs * 0.10))
                p.addQuadCurve(to: CGPoint(x: fs * 0.12, y: fs * 0.10),
                               control: CGPoint(x: 0, y: fs * 0.22))
            }.stroke(Color(red: 0.18, green: 0.48, blue: 0.18), lineWidth: 1.4)
        }
        .offset(y: frogJumpY)
        .position(x: w * 0.192, y: h * 0.628)
    }

    // MARK: - Butterfly
    @ViewBuilder
    private func butterflyView(w: CGFloat, h: CGFloat,
                               centerX: CGFloat, centerY: CGFloat,
                               radiusX: CGFloat, radiusY: CGFloat,
                               angle: Double, color: Color) -> some View {
        let bx = w * centerX + w * radiusX * cos(angle * .pi / 180)
        let by = h * centerY + h * radiusY * sin(angle * .pi / 180)
        let bs = w * 0.022
        let wScale: CGFloat = wingToggle ? 1.0 : 0.20

        ZStack {
            // 左翅
            Ellipse()
                .fill(color.opacity(0.90))
                .frame(width: bs, height: bs * 0.62)
                .offset(x: -bs * 0.48)
                .scaleEffect(CGSize(width: wScale, height: 1), anchor: .trailing)
                .animation(.easeInOut(duration: 0.17), value: wingToggle)
            // 右翅
            Ellipse()
                .fill(color.opacity(0.90))
                .frame(width: bs, height: bs * 0.62)
                .offset(x:  bs * 0.48)
                .scaleEffect(CGSize(width: wScale, height: 1), anchor: .leading)
                .animation(.easeInOut(duration: 0.17), value: wingToggle)
            // 身体
            Capsule()
                .fill(Color(red: 0.18, green: 0.12, blue: 0.08))
                .frame(width: bs * 0.14, height: bs * 0.50)
            // 触角
            Path { p in
                p.move(to: CGPoint(x: -bs*0.05, y: -bs*0.20))
                p.addQuadCurve(to: CGPoint(x: -bs*0.22, y: -bs*0.52),
                               control: CGPoint(x: -bs*0.18, y: -bs*0.32))
                p.move(to: CGPoint(x:  bs*0.05, y: -bs*0.20))
                p.addQuadCurve(to: CGPoint(x:  bs*0.22, y: -bs*0.52),
                               control: CGPoint(x:  bs*0.18, y: -bs*0.32))
            }.stroke(Color(red: 0.20, green: 0.14, blue: 0.08), lineWidth: 1.0)
            Circle().fill(color).frame(width: bs * 0.12).offset(x: -bs*0.22, y: -bs*0.52)
            Circle().fill(color).frame(width: bs * 0.12).offset(x:  bs*0.22, y: -bs*0.52)
        }
        .position(x: bx, y: by)
    }

    // MARK: - Cat
    @ViewBuilder
    private func catView(w: CGFloat, h: CGFloat) -> some View {
        let cs = w * 0.054
        ZStack {
            // 地面投影
            Ellipse()
                .fill(Color.black.opacity(0.10))
                .frame(width: cs * 1.05, height: cs * 0.20)
                .offset(y: cs * 0.54)

            Group {
                switch catState {
                case .sleeping:          sleepingCat(cs: cs)
                case .sitting, .wandering: sittingCat(cs: cs)
                case .playing:           playingCat(cs: cs)
                }
            }
            .offset(y: catBounce)

            // 点击爱心
            if catHeartVisible {
                Image(systemName: "heart.fill")
                    .font(.system(size: cs * 0.50))
                    .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.55))
                    .offset(y: -cs * 0.95)
                    .transition(.scale.combined(with: .opacity))
            }

            // 睡觉 zzz
            if catState == .sleeping {
                Text("z z z")
                    .font(.system(size: cs * 0.30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.52, green: 0.52, blue: 0.88))
                    .offset(x: cs * 0.60, y: -cs * 0.55)
            }
        }
        .scaleEffect(x: catFaceRight ? 1 : -1, y: 1)
        .position(x: catX * w, y: catY * h)
        .onTapGesture { handleCatTap() }
        .animation(.easeInOut(duration: 2.0), value: catX)
        .animation(.easeInOut(duration: 2.0), value: catY)
    }

    // MARK: Cat poses
    @ViewBuilder
    private func sittingCat(cs: CGFloat) -> some View {
        ZStack {
            // 身体
            RoundedRectangle(cornerRadius: cs * 0.28)
                .fill(Color(red: 0.94, green: 0.88, blue: 0.80))
                .frame(width: cs * 0.70, height: cs * 0.72)
                .offset(y: cs * 0.12)
            // 橙色斑纹（三花）
            Circle()
                .fill(Color(red: 0.82, green: 0.50, blue: 0.20).opacity(0.50))
                .frame(width: cs * 0.28)
                .offset(x: cs * 0.10, y: cs * 0.05)
            // 头
            Circle()
                .fill(Color(red: 0.94, green: 0.88, blue: 0.80))
                .frame(width: cs * 0.72)
                .offset(y: -cs * 0.28)
            // 深色头部斑纹
            Circle()
                .fill(Color(red: 0.38, green: 0.24, blue: 0.14).opacity(0.45))
                .frame(width: cs * 0.30)
                .offset(x: cs * 0.12, y: -cs * 0.38)
            // 耳朵（外）
            Triangle().fill(Color(red: 0.90, green: 0.78, blue: 0.68))
                .frame(width: cs * 0.22, height: cs * 0.24)
                .offset(x: -cs * 0.20, y: -cs * 0.60)
            // 耳朵（内粉）
            Triangle().fill(Color(red: 1.0, green: 0.78, blue: 0.82))
                .frame(width: cs * 0.13, height: cs * 0.14)
                .offset(x: -cs * 0.20, y: -cs * 0.60)
            Triangle().fill(Color(red: 0.90, green: 0.78, blue: 0.68))
                .frame(width: cs * 0.22, height: cs * 0.24)
                .offset(x:  cs * 0.20, y: -cs * 0.60)
            Triangle().fill(Color(red: 1.0, green: 0.78, blue: 0.82))
                .frame(width: cs * 0.13, height: cs * 0.14)
                .offset(x:  cs * 0.20, y: -cs * 0.60)
            // 眼睛（绿色）
            Ellipse().fill(Color(red: 0.25, green: 0.58, blue: 0.28))
                .frame(width: cs * 0.17, height: cs * 0.15)
                .offset(x: -cs * 0.15, y: -cs * 0.28)
            Ellipse().fill(Color(red: 0.25, green: 0.58, blue: 0.28))
                .frame(width: cs * 0.17, height: cs * 0.15)
                .offset(x:  cs * 0.15, y: -cs * 0.28)
            // 瞳孔
            Ellipse().fill(Color.black)
                .frame(width: cs * 0.08, height: cs * 0.13)
                .offset(x: -cs * 0.15, y: -cs * 0.28)
            Ellipse().fill(Color.black)
                .frame(width: cs * 0.08, height: cs * 0.13)
                .offset(x:  cs * 0.15, y: -cs * 0.28)
            // 鼻子
            Triangle().fill(Color(red: 1.0, green: 0.62, blue: 0.70))
                .frame(width: cs * 0.10, height: cs * 0.07)
                .offset(y: -cs * 0.20)
            // 胡须
            ForEach([-1, 0, 1], id: \.self) { i in
                Rectangle()
                    .fill(Color(red: 0.65, green: 0.55, blue: 0.50).opacity(0.65))
                    .frame(width: cs * 0.26, height: 0.8)
                    .offset(x: -cs * 0.38, y: CGFloat(i) * cs * 0.055 - cs * 0.20)
                    .rotationEffect(.degrees(Double(i) * 12))
                Rectangle()
                    .fill(Color(red: 0.65, green: 0.55, blue: 0.50).opacity(0.65))
                    .frame(width: cs * 0.26, height: 0.8)
                    .offset(x:  cs * 0.38, y: CGFloat(i) * cs * 0.055 - cs * 0.20)
                    .rotationEffect(.degrees(Double(-i) * 12))
            }
            // 尾巴
            Path { p in
                p.move(to: CGPoint(x: cs * 0.30, y: cs * 0.38))
                p.addCurve(to: CGPoint(x: cs * 0.58, y: cs * 0.08),
                           control1: CGPoint(x: cs * 0.72, y: cs * 0.46),
                           control2: CGPoint(x: cs * 0.80, y: cs * 0.20))
            }
            .stroke(Color(red: 0.90, green: 0.80, blue: 0.70), lineWidth: cs * 0.14)
            .offset(y: cs * 0.12)
        }
    }

    @ViewBuilder
    private func sleepingCat(cs: CGFloat) -> some View {
        ZStack {
            // 蜷缩身体
            Ellipse()
                .fill(Color(red: 0.94, green: 0.88, blue: 0.80))
                .frame(width: cs * 1.0, height: cs * 0.52)
            // 头部侧放
            Circle()
                .fill(Color(red: 0.94, green: 0.88, blue: 0.80))
                .frame(width: cs * 0.60)
                .offset(x: cs * 0.28, y: -cs * 0.07)
            // 耳朵
            Triangle().fill(Color(red: 0.90, green: 0.78, blue: 0.68))
                .frame(width: cs * 0.18, height: cs * 0.20)
                .offset(x: cs * 0.25, y: -cs * 0.28)
            // 闭眼弧线
            Path { p in
                p.move(to:    CGPoint(x: cs * 0.22, y: -cs * 0.04))
                p.addQuadCurve(to: CGPoint(x: cs * 0.36, y: -cs * 0.04),
                               control: CGPoint(x: cs * 0.29, y: -cs * 0.12))
                p.move(to:    CGPoint(x: cs * 0.40, y: -cs * 0.04))
                p.addQuadCurve(to: CGPoint(x: cs * 0.53, y: -cs * 0.04),
                               control: CGPoint(x: cs * 0.465, y: -cs * 0.12))
            }.stroke(Color(red: 0.40, green: 0.30, blue: 0.25), lineWidth: 1.5)
            // 尾巴
            Path { p in
                p.move(to: CGPoint(x: -cs * 0.42, y: cs * 0.10))
                p.addCurve(to: CGPoint(x: cs * 0.12, y: cs * 0.28),
                           control1: CGPoint(x: -cs * 0.52, y: cs * 0.35),
                           control2: CGPoint(x: -cs * 0.10, y: cs * 0.40))
            }.stroke(Color(red: 0.90, green: 0.80, blue: 0.70), lineWidth: cs * 0.13)
        }
    }

    @ViewBuilder
    private func playingCat(cs: CGFloat) -> some View {
        ZStack {
            sittingCat(cs: cs)
            // 抬起的爪子
            Circle()
                .fill(Color(red: 0.94, green: 0.88, blue: 0.80))
                .frame(width: cs * 0.24)
                .offset(x: cs * 0.40, y: -cs * 0.42 + catBounce * 0.4)
        }
    }

    // MARK: - Tap
    private func handleCatTap() {
        onCatTap()
        withAnimation(.spring(response: 0.22, dampingFraction: 0.40)
                        .repeatCount(3, autoreverses: true)) {
            catBounce = -10
        }
        withAnimation(.easeIn(duration: 0.12)) { catHeartVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { catBounce = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.60) {
            withAnimation(.easeOut(duration: 0.30)) { catHeartVisible = false }
        }
    }

    // MARK: - Animation start
    private func startAnimations(w: CGFloat, h: CGFloat) {
        // 蝴蝶轨道
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false))  { bf1Angle = 360 }
        withAnimation(.linear(duration: 13).repeatForever(autoreverses: false)) { bf2Angle = 540 }
        // 翅膀扇动
        Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { _ in wingToggle.toggle() }
        // 青蛙跳跃
        Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { _ in
            withAnimation(.spring(response: 0.26, dampingFraction: 0.46)) { frogJumpY = -16 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.62)) { frogJumpY = 0 }
            }
        }
        // 猫状态机
        runCatBehavior(w: w, h: h)
    }

    private func runCatBehavior(w: CGFloat, h: CGFloat) {
        let durations: [CatState: ClosedRange<Double>] = [
            .sleeping:  6...11, .sitting:  3...6,
            .playing:   4...7,  .wandering: 5...9
        ]
        let dur = durations[catState].map { Double.random(in: $0) } ?? 4.0

        if catState == .playing {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.36)
                            .repeatCount(10, autoreverses: true)) { catBounce = -9 }
        } else {
            withAnimation(.spring()) { catBounce = 0 }
        }

        // 游荡时在水池旁几个落点间移动
        if catState == .wandering {
            let waypoints: [(CGFloat, CGFloat, Bool)] = [
                (0.38, 0.65, false), (0.43, 0.66, false),
                (0.41, 0.62, false), (0.45, 0.64, false)
            ]
            let wp = waypoints.randomElement()!
            catFaceRight = wp.2
            catX = wp.0; catY = wp.1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
            catState = CatState.allCases.randomElement()!
            runCatBehavior(w: w, h: h)
        }
    }
}
