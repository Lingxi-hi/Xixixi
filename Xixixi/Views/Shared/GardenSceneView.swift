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
struct GardenSceneView: View {
    var onCatTap: () -> Void

    // Cat
    @State private var catState: CatState = .sitting
    @State private var catX: CGFloat = 0.42
    @State private var catY: CGFloat = 0.64
    @State private var catFaceRight: Bool = true
    @State private var catBounce: CGFloat = 0
    @State private var catHeartVisible: Bool = false

    // Butterflies
    @State private var bf1Angle: Double = 0
    @State private var bf2Angle: Double = 180
    @State private var wingToggle: Bool = false

    // Frog
    @State private var frogJumpY: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                gardenBackground(w: w, h: h)
                frogView(w: w, h: h)
                butterflyView(w: w, h: h, angle: bf2Angle, color: Color(red:1.0,green:0.72,blue:0.12))
                butterflyView(w: w, h: h, angle: bf1Angle, color: Color(red:0.64,green:0.36,blue:0.92))
                catView(w: w, h: h)
            }
            .clipped()
            .onAppear { startAnimations(w: w, h: h) }
        }
    }

    // MARK: - Background
    @ViewBuilder
    private func gardenBackground(w: CGFloat, h: CGFloat) -> some View {
        // Sky
        LinearGradient(colors: [Color(red:0.50,green:0.78,blue:0.96),
                                Color(red:0.76,green:0.91,blue:0.99),
                                Color(red:0.90,green:0.97,blue:1.00)],
                       startPoint: .top, endPoint: .bottom)
            .frame(width: w, height: h * 0.55)

        // Clouds
        Capsule().fill(Color.white.opacity(0.90))
            .frame(width: w*0.14, height: h*0.07)
            .position(x: w*0.18, y: h*0.10)
        Capsule().fill(Color.white.opacity(0.85))
            .frame(width: w*0.20, height: h*0.08)
            .position(x: w*0.52, y: h*0.14)
        Capsule().fill(Color.white.opacity(0.80))
            .frame(width: w*0.12, height: h*0.06)
            .position(x: w*0.80, y: h*0.09)

        // Background big trees (corners)
        bgTree(w: w, h: h, x: 0.05, y: 0.40, fw: 0.13, fh: 0.22, clr: Color(red:0.28,green:0.52,blue:0.22))
        bgTree(w: w, h: h, x: 0.91, y: 0.38, fw: 0.11, fh: 0.19, clr: Color(red:0.30,green:0.55,blue:0.24))

        // Far background tree cluster
        Circle().fill(Color(red:0.32,green:0.58,blue:0.26).opacity(0.75))
            .frame(width: w*0.08).position(x: w*0.30, y: h*0.28)
        Circle().fill(Color(red:0.26,green:0.50,blue:0.22).opacity(0.70))
            .frame(width: w*0.06).position(x: w*0.37, y: h*0.30)

        // Ground (wavy grass hill)
        Path { p in
            p.move(to: CGPoint(x: 0, y: h*0.47))
            p.addCurve(to: CGPoint(x: w, y: h*0.43),
                       control1: CGPoint(x: w*0.28, y: h*0.41),
                       control2: CGPoint(x: w*0.70, y: h*0.49))
            p.addLine(to: CGPoint(x: w, y: h))
            p.addLine(to: CGPoint(x: 0, y: h))
            p.closeSubpath()
        }.fill(Color(red:0.52,green:0.76,blue:0.38))

        Path { p in
            p.move(to: CGPoint(x: 0, y: h*0.66))
            p.addLine(to: CGPoint(x: w, y: h*0.66))
            p.addLine(to: CGPoint(x: w, y: h))
            p.addLine(to: CGPoint(x: 0, y: h))
            p.closeSubpath()
        }.fill(Color(red:0.42,green:0.63,blue:0.28))

        // Stone wall (background left-center)
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red:0.62,green:0.58,blue:0.54))
            .frame(width: w*0.28, height: h*0.11)
            .position(x: w*0.28, y: h*0.445)

        // Pergola posts
        Rectangle().fill(Color(red:0.52,green:0.38,blue:0.22))
            .frame(width: w*0.008, height: h*0.16).position(x: w*0.305, y: h*0.40)
        Rectangle().fill(Color(red:0.52,green:0.38,blue:0.22))
            .frame(width: w*0.008, height: h*0.16).position(x: w*0.385, y: h*0.40)
        Rectangle().fill(Color(red:0.52,green:0.38,blue:0.22))
            .frame(width: w*0.088, height: h*0.012).position(x: w*0.345, y: h*0.32)

        // Bench
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(red:0.56,green:0.40,blue:0.22))
            .frame(width: w*0.08, height: h*0.022).position(x: w*0.345, y: h*0.455)

        // Cottage (right)
        cottage(w: w, h: h)

        // Pond (left)
        pond(w: w, h: h)

        // Winding path
        Path { p in
            p.move(to: CGPoint(x: w*0.42, y: h))
            p.addCurve(to: CGPoint(x: w*0.75, y: h*0.58),
                       control1: CGPoint(x: w*0.45, y: h*0.80),
                       control2: CGPoint(x: w*0.56, y: h*0.65))
            p.addCurve(to: CGPoint(x: w*0.84, y: h*0.70),
                       control1: CGPoint(x: w*0.83, y: h*0.56),
                       control2: CGPoint(x: w*0.87, y: h*0.62))
        }
        .stroke(Color(red:0.74,green:0.61,blue:0.43), lineWidth: w*0.042)

        // Path pebbles
        ForEach([CGPoint(x:0.49,y:0.79), CGPoint(x:0.54,y:0.72),
                 CGPoint(x:0.60,y:0.66), CGPoint(x:0.66,y:0.62)], id: \.x) { pt in
            Ellipse().fill(Color(red:0.63,green:0.61,blue:0.57).opacity(0.7))
                .frame(width: w*0.012, height: h*0.010)
                .position(x: pt.x*w, y: pt.y*h)
        }

        // Foreground tree (mid-left)
        fgTree(w: w, h: h, x: 0.08, y: 0.56, fw: 0.10, fh: 0.14, clr: Color(red:0.38,green:0.65,blue:0.28))

        // Decorations: flowers & mushrooms
        decorations(w: w, h: h)

        // Rock cat sits on
        Ellipse().fill(Color(red:0.58,green:0.56,blue:0.52))
            .frame(width: w*0.048, height: h*0.038)
            .position(x: w*0.395, y: h*0.635)
    }

    // MARK: - Background tree
    @ViewBuilder
    private func bgTree(w: CGFloat, h: CGFloat, x: CGFloat, y: CGFloat,
                        fw: CGFloat, fh: CGFloat, clr: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red:0.38,green:0.24,blue:0.10))
                .frame(width: w*0.025, height: h*0.20)
                .offset(y: h*fh*0.38)
            Ellipse().fill(clr)
                .frame(width: w*fw, height: h*fh)
        }
        .position(x: w*x, y: h*y)
    }

    @ViewBuilder
    private func fgTree(w: CGFloat, h: CGFloat, x: CGFloat, y: CGFloat,
                        fw: CGFloat, fh: CGFloat, clr: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red:0.38,green:0.24,blue:0.10))
                .frame(width: w*0.020, height: h*0.16)
                .offset(y: h*fh*0.38)
            Ellipse().fill(clr)
                .frame(width: w*fw, height: h*fh)
        }
        .position(x: w*x, y: h*y)
    }

    // MARK: - Cottage
    @ViewBuilder
    private func cottage(w: CGFloat, h: CGFloat) -> some View {
        // Wall
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(red:0.74,green:0.60,blue:0.44))
            .frame(width: w*0.13, height: h*0.20)
            .position(x: w*0.79, y: h*0.475)

        // Stone base
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red:0.60,green:0.55,blue:0.50))
            .frame(width: w*0.13, height: h*0.055)
            .position(x: w*0.79, y: h*0.545)

        // Thatched roof
        Path { p in
            let cx = w*0.79
            let top = h*0.275
            p.move(to: CGPoint(x: cx - w*0.09, y: top + h*0.08))
            p.addLine(to: CGPoint(x: cx, y: top))
            p.addLine(to: CGPoint(x: cx + w*0.09, y: top + h*0.08))
            p.closeSubpath()
        }.fill(Color(red:0.76,green:0.63,blue:0.28))

        // Chimney
        Rectangle().fill(Color(red:0.60,green:0.48,blue:0.36))
            .frame(width: w*0.022, height: h*0.048)
            .position(x: w*0.81, y: h*0.272)

        // Door
        Circle().fill(Color(red:0.45,green:0.30,blue:0.15))
            .frame(width: w*0.038).position(x: w*0.79, y: h*0.500)

        // Window
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(red:0.65,green:0.85,blue:0.95).opacity(0.8))
            .frame(width: w*0.035, height: h*0.052)
            .position(x: w*0.765, y: h*0.458)

        // 乐园 sign
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red:0.68,green:0.50,blue:0.28))
                .frame(width: w*0.058, height: h*0.072)
            Text("乐园")
                .font(.system(size: min(w,h)*0.024, weight: .bold, design: .rounded))
                .foregroundColor(Color(red:0.96,green:0.88,blue:0.65))
        }
        .position(x: w*0.905, y: h*0.550)

        Rectangle().fill(Color(red:0.58,green:0.42,blue:0.22))
            .frame(width: w*0.006, height: h*0.055)
            .position(x: w*0.905, y: h*0.618)
    }

    // MARK: - Pond
    @ViewBuilder
    private func pond(w: CGFloat, h: CGFloat) -> some View {
        let px = w*0.175, py = h*0.625
        let pw = w*0.19,  ph = h*0.20

        // Stone border
        Ellipse().fill(Color(red:0.56,green:0.52,blue:0.49))
            .frame(width: pw + w*0.026, height: ph + h*0.030)
            .position(x: px, y: py)

        // Water
        Ellipse().fill(Color(red:0.46,green:0.73,blue:0.88))
            .frame(width: pw, height: ph)
            .position(x: px, y: py)

        // Shimmer
        Ellipse()
            .fill(RadialGradient(colors: [Color.white.opacity(0.35), .clear],
                                 center: .topLeading, startRadius: 0, endRadius: pw*0.6))
            .frame(width: pw, height: ph)
            .position(x: px, y: py)

        // Lily pads
        Circle().fill(Color(red:0.30,green:0.62,blue:0.28))
            .frame(width: w*0.028).position(x: px - pw*0.16, y: py + ph*0.06)
        Circle().fill(Color(red:0.26,green:0.57,blue:0.24))
            .frame(width: w*0.020).position(x: px + pw*0.10, y: py + ph*0.10)

        // Reed
        Rectangle().fill(Color(red:0.28,green:0.52,blue:0.25))
            .frame(width: w*0.006, height: h*0.075)
            .position(x: px - pw*0.26, y: py - ph*0.12)
        Capsule().fill(Color(red:0.44,green:0.28,blue:0.12))
            .frame(width: w*0.010, height: h*0.028)
            .position(x: px - pw*0.26, y: py - ph*0.23)
    }

    // MARK: - Decorations
    @ViewBuilder
    private func decorations(w: CGFloat, h: CGFloat) -> some View {
        // Red mushrooms
        mushroom(w:w, h:h, x:0.485, y:0.710, s:1.00, red:true)
        mushroom(w:w, h:h, x:0.502, y:0.695, s:0.72, red:true)
        mushroom(w:w, h:h, x:0.535, y:0.715, s:0.58, red:false)
        mushroom(w:w, h:h, x:0.840, y:0.670, s:0.90, red:true)
        mushroom(w:w, h:h, x:0.858, y:0.658, s:0.65, red:false)

        // Flowers
        flower(w:w, h:h, x:0.335, y:0.555, clr:Color(red:1.0,green:0.35,blue:0.35))
        flower(w:w, h:h, x:0.222, y:0.775, clr:Color(red:1.0,green:0.88,blue:0.15))
        flower(w:w, h:h, x:0.265, y:0.748, clr:Color(red:1.0,green:0.92,blue:0.20))
        flower(w:w, h:h, x:0.720, y:0.600, clr:Color(red:0.58,green:0.78,blue:1.0))
        flower(w:w, h:h, x:0.760, y:0.628, clr:Color(red:0.65,green:0.82,blue:1.0))
        flower(w:w, h:h, x:0.885, y:0.715, clr:.white)
        flower(w:w, h:h, x:0.928, y:0.688, clr:.white)
    }

    @ViewBuilder
    private func mushroom(w: CGFloat, h: CGFloat, x: CGFloat, y: CGFloat, s: CGFloat, red: Bool) -> some View {
        let mw = w*0.022*s, mh = h*0.042*s
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.88))
                .frame(width: mw*0.45, height: mh*0.48)
                .offset(y: mh*0.28)
            Ellipse()
                .fill(red ? Color(red:0.90,green:0.18,blue:0.12) : Color(red:0.62,green:0.36,blue:0.16))
                .frame(width: mw, height: mh*0.54)
            if red {
                Circle().fill(Color.white.opacity(0.85)).frame(width: mw*0.18).offset(x: -mw*0.20, y: -mh*0.05)
                Circle().fill(Color.white.opacity(0.85)).frame(width: mw*0.14).offset(x:  mw*0.18, y:  mh*0.02)
            }
        }
        .frame(width: mw, height: mh)
        .position(x: x*w, y: y*h)
    }

    @ViewBuilder
    private func flower(w: CGFloat, h: CGFloat, x: CGFloat, y: CGFloat, clr: Color) -> some View {
        let fw = w*0.018
        ZStack {
            Rectangle().fill(Color(red:0.35,green:0.65,blue:0.28))
                .frame(width: fw*0.14, height: fw*0.90).offset(y: fw*0.50)
            ForEach(0..<4, id: \.self) { i in
                Ellipse().fill(clr)
                    .frame(width: fw*0.35, height: fw*0.55)
                    .offset(y: -fw*0.18)
                    .rotationEffect(.degrees(Double(i)*90))
            }
            Circle().fill(Color(red:1.0,green:0.88,blue:0.25)).frame(width: fw*0.34)
        }
        .frame(width: fw, height: fw)
        .position(x: x*w, y: y*h)
    }

    // MARK: - Frog
    @ViewBuilder
    private func frogView(w: CGFloat, h: CGFloat) -> some View {
        let fs = w*0.036
        ZStack {
            // body
            Ellipse().fill(Color(red:0.30,green:0.68,blue:0.32))
                .frame(width: fs, height: fs*0.72)
            // belly
            Ellipse().fill(Color(red:0.72,green:0.90,blue:0.55).opacity(0.6))
                .frame(width: fs*0.55, height: fs*0.40).offset(y: fs*0.08)
            // eye bumps
            Circle().fill(Color(red:0.26,green:0.60,blue:0.28))
                .frame(width: fs*0.36).offset(x: -fs*0.18, y: -fs*0.28)
            Circle().fill(Color(red:0.26,green:0.60,blue:0.28))
                .frame(width: fs*0.36).offset(x:  fs*0.18, y: -fs*0.28)
            // pupils
            Circle().fill(.black.opacity(0.85)).frame(width: fs*0.15).offset(x: -fs*0.18, y: -fs*0.28)
            Circle().fill(.black.opacity(0.85)).frame(width: fs*0.15).offset(x:  fs*0.18, y: -fs*0.28)
            // smile
            Path { p in
                p.move(to: CGPoint(x: -fs*0.12, y: fs*0.10))
                p.addQuadCurve(to: CGPoint(x: fs*0.12, y: fs*0.10),
                               control: CGPoint(x: 0, y: fs*0.22))
            }.stroke(Color(red:0.20,green:0.50,blue:0.20), lineWidth: 1.4)
        }
        .offset(y: frogJumpY)
        .position(x: w*0.155, y: h*0.658)
    }

    // MARK: - Butterfly
    @ViewBuilder
    private func butterflyView(w: CGFloat, h: CGFloat, angle: Double, color: Color) -> some View {
        let cx = w*0.42, cy = h*0.50
        let rx = w*0.13, ry = h*0.08
        let bx = cx + rx * cos(angle * .pi / 180)
        let by = cy + ry * sin(angle * .pi / 180)
        let bs = w*0.024
        let wScale: CGFloat = wingToggle ? 1.0 : 0.22

        ZStack {
            // left wing
            Ellipse().fill(color.opacity(0.88))
                .frame(width: bs, height: bs*0.65)
                .offset(x: -bs*0.50)
                .scaleEffect(CGSize(width: wScale, height: 1), anchor: .trailing)
                .animation(.easeInOut(duration: 0.18), value: wingToggle)
            // right wing
            Ellipse().fill(color.opacity(0.88))
                .frame(width: bs, height: bs*0.65)
                .offset(x: bs*0.50)
                .scaleEffect(CGSize(width: wScale, height: 1), anchor: .leading)
                .animation(.easeInOut(duration: 0.18), value: wingToggle)
            // body
            Capsule().fill(Color(red:0.18,green:0.12,blue:0.08))
                .frame(width: bs*0.14, height: bs*0.50)
        }
        .position(x: bx, y: by)
    }

    // MARK: - Cat
    @ViewBuilder
    private func catView(w: CGFloat, h: CGFloat) -> some View {
        let cs = w*0.056
        ZStack {
            // shadow
            Ellipse().fill(Color.black.opacity(0.10))
                .frame(width: cs*1.1, height: cs*0.22)
                .offset(y: cs*0.56)

            Group {
                switch catState {
                case .sleeping:  sleepingCat(cs: cs)
                case .sitting, .wandering: sittingCat(cs: cs)
                case .playing:   playingCat(cs: cs)
                }
            }
            .offset(y: catBounce)

            // floating heart on tap
            if catHeartVisible {
                Image(systemName: "heart.fill")
                    .font(.system(size: cs*0.50))
                    .foregroundStyle(Color(red:1.0,green:0.35,blue:0.55))
                    .offset(y: -cs*0.95)
                    .transition(.scale.combined(with: .opacity))
            }

            // zzz when sleeping
            if catState == .sleeping {
                Text("z z z")
                    .font(.system(size: cs*0.32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red:0.52,green:0.52,blue:0.88))
                    .offset(x: cs*0.55, y: -cs*0.58)
            }
        }
        .scaleEffect(x: catFaceRight ? 1 : -1, y: 1)
        .position(x: catX * w, y: catY * h)
        .onTapGesture { handleCatTap() }
        .animation(.easeInOut(duration: 1.8), value: catX)
        .animation(.easeInOut(duration: 1.8), value: catY)
    }

    // MARK: Cat body shapes
    @ViewBuilder
    private func sittingCat(cs: CGFloat) -> some View {
        ZStack {
            // body
            RoundedRectangle(cornerRadius: cs*0.28)
                .fill(Color(red:0.92,green:0.82,blue:0.72))
                .frame(width: cs*0.70, height: cs*0.72).offset(y: cs*0.12)
            // orange patch on body
            Circle().fill(Color(red:0.82,green:0.52,blue:0.22).opacity(0.45))
                .frame(width: cs*0.28).offset(x: cs*0.10, y: cs*0.05)
            // head
            Circle().fill(Color(red:0.92,green:0.82,blue:0.72))
                .frame(width: cs*0.72).offset(y: -cs*0.28)
            // dark head patch
            Circle().fill(Color(red:0.38,green:0.24,blue:0.14).opacity(0.42))
                .frame(width: cs*0.30).offset(x: cs*0.12, y: -cs*0.38)
            // ears
            Triangle().fill(Color(red:0.88,green:0.76,blue:0.66))
                .frame(width: cs*0.22, height: cs*0.24).offset(x: -cs*0.20, y: -cs*0.60)
            Triangle().fill(Color(red:1.0,green:0.78,blue:0.82))
                .frame(width: cs*0.13, height: cs*0.14).offset(x: -cs*0.20, y: -cs*0.60)
            Triangle().fill(Color(red:0.88,green:0.76,blue:0.66))
                .frame(width: cs*0.22, height: cs*0.24).offset(x:  cs*0.20, y: -cs*0.60)
            Triangle().fill(Color(red:1.0,green:0.78,blue:0.82))
                .frame(width: cs*0.13, height: cs*0.14).offset(x:  cs*0.20, y: -cs*0.60)
            // eyes
            Ellipse().fill(Color(red:0.25,green:0.56,blue:0.28))
                .frame(width: cs*0.16, height: cs*0.14).offset(x: -cs*0.15, y: -cs*0.28)
            Ellipse().fill(Color(red:0.25,green:0.56,blue:0.28))
                .frame(width: cs*0.16, height: cs*0.14).offset(x:  cs*0.15, y: -cs*0.28)
            Ellipse().fill(.black)
                .frame(width: cs*0.08, height: cs*0.12).offset(x: -cs*0.15, y: -cs*0.28)
            Ellipse().fill(.black)
                .frame(width: cs*0.08, height: cs*0.12).offset(x:  cs*0.15, y: -cs*0.28)
            // nose
            Triangle().fill(Color(red:1.0,green:0.65,blue:0.72))
                .frame(width: cs*0.10, height: cs*0.07).offset(y: -cs*0.20)
            // whiskers
            ForEach([-1, 0, 1], id: \.self) { i in
                Rectangle().fill(Color(red:0.65,green:0.55,blue:0.50).opacity(0.65))
                    .frame(width: cs*0.25, height: 0.8)
                    .offset(x: -cs*0.38, y: CGFloat(i)*cs*0.055 - cs*0.20)
                    .rotationEffect(.degrees(Double(i)*12))
                Rectangle().fill(Color(red:0.65,green:0.55,blue:0.50).opacity(0.65))
                    .frame(width: cs*0.25, height: 0.8)
                    .offset(x:  cs*0.38, y: CGFloat(i)*cs*0.055 - cs*0.20)
                    .rotationEffect(.degrees(Double(-i)*12))
            }
            // tail
            Path { p in
                p.move(to: CGPoint(x: cs*0.30, y: cs*0.38))
                p.addCurve(to: CGPoint(x: cs*0.58, y: cs*0.08),
                           control1: CGPoint(x: cs*0.72, y: cs*0.46),
                           control2: CGPoint(x: cs*0.80, y: cs*0.20))
            }
            .stroke(Color(red:0.88,green:0.78,blue:0.68), lineWidth: cs*0.14)
            .offset(y: cs*0.12)
        }
    }

    @ViewBuilder
    private func sleepingCat(cs: CGFloat) -> some View {
        ZStack {
            // curled body
            Ellipse().fill(Color(red:0.92,green:0.82,blue:0.72))
                .frame(width: cs*1.0, height: cs*0.52)
            // head at side
            Circle().fill(Color(red:0.92,green:0.82,blue:0.72))
                .frame(width: cs*0.60).offset(x: cs*0.28, y: -cs*0.07)
            // ear
            Triangle().fill(Color(red:0.88,green:0.76,blue:0.66))
                .frame(width: cs*0.18, height: cs*0.20).offset(x: cs*0.25, y: -cs*0.28)
            // closed eyes (arc)
            Path { p in
                p.move(to: CGPoint(x: cs*0.22, y: -cs*0.04))
                p.addQuadCurve(to: CGPoint(x: cs*0.36, y: -cs*0.04),
                               control: CGPoint(x: cs*0.29, y: -cs*0.12))
                p.move(to: CGPoint(x: cs*0.39, y: -cs*0.04))
                p.addQuadCurve(to: CGPoint(x: cs*0.52, y: -cs*0.04),
                               control: CGPoint(x: cs*0.455, y: -cs*0.12))
            }.stroke(Color(red:0.40,green:0.30,blue:0.25), lineWidth: 1.5)
            // tail wrapped
            Path { p in
                p.move(to: CGPoint(x: -cs*0.42, y: cs*0.10))
                p.addCurve(to: CGPoint(x: cs*0.12, y: cs*0.28),
                           control1: CGPoint(x: -cs*0.52, y: cs*0.35),
                           control2: CGPoint(x: -cs*0.10, y: cs*0.40))
            }.stroke(Color(red:0.88,green:0.78,blue:0.68), lineWidth: cs*0.13)
        }
    }

    @ViewBuilder
    private func playingCat(cs: CGFloat) -> some View {
        ZStack {
            sittingCat(cs: cs)
            // raised paw
            Circle().fill(Color(red:0.92,green:0.82,blue:0.72))
                .frame(width: cs*0.24)
                .offset(x: cs*0.40, y: -cs*0.42 + catBounce * 0.4)
        }
    }

    // MARK: - Tap handler
    private func handleCatTap() {
        onCatTap()
        withAnimation(.spring(response: 0.22, dampingFraction: 0.40).repeatCount(3, autoreverses: true)) {
            catBounce = -10
        }
        withAnimation(.easeIn(duration: 0.12)) { catHeartVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { catBounce = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.60) {
            withAnimation(.easeOut(duration: 0.30)) { catHeartVisible = false }
        }
    }

    // MARK: - Animation startup
    private func startAnimations(w: CGFloat, h: CGFloat) {
        // Butterfly orbits
        withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
            bf1Angle = 360
        }
        withAnimation(.linear(duration: 13).repeatForever(autoreverses: false)) {
            bf2Angle = 540
        }
        // Wing flap timer
        Timer.scheduledTimer(withTimeInterval: 0.20, repeats: true) { _ in
            wingToggle.toggle()
        }
        // Frog jump timer
        Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { _ in
            withAnimation(.spring(response: 0.28, dampingFraction: 0.48)) { frogJumpY = -18 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.60)) { frogJumpY = 0 }
            }
        }
        // Cat state machine
        runCatBehavior(w: w, h: h)
    }

    private func runCatBehavior(w: CGFloat, h: CGFloat) {
        let durations: [CatState: ClosedRange<Double>] = [
            .sleeping:  6...10,
            .sitting:   3...6,
            .playing:   4...7,
            .wandering: 5...8,
        ]
        let dur = durations[catState].map { Double.random(in: $0) } ?? 4.0

        // Apply state visuals
        if catState == .playing {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.38).repeatCount(8, autoreverses: true)) {
                catBounce = -9
            }
        } else {
            withAnimation(.spring()) { catBounce = 0 }
        }

        if catState == .wandering {
            let waypoints: [(CGFloat,CGFloat)] = [
                (0.36, 0.65), (0.44, 0.66), (0.40, 0.62), (0.46, 0.64)
            ]
            let wp = waypoints.randomElement()!
            catFaceRight = wp.0 > catX
            catX = wp.0
            catY = wp.1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
            catState = CatState.allCases.randomElement()!
            runCatBehavior(w: w, h: h)
        }
    }
}
