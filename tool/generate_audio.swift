import Foundation

let output = CommandLine.arguments.dropFirst().first ?? "assets/audio"
let sampleRate = 44100

func writeWav(_ path: String, samples: [Int16]) {
    var data = Data()
    func u16(_ value: UInt16) { data.append(contentsOf: [UInt8(value & 255), UInt8(value >> 8)]) }
    func u32(_ value: UInt32) { data.append(contentsOf: [UInt8(value & 255), UInt8((value >> 8) & 255), UInt8((value >> 16) & 255), UInt8(value >> 24)]) }
    data.append(contentsOf: Array("RIFF".utf8)); u32(UInt32(36 + samples.count * 2)); data.append(contentsOf: Array("WAVE".utf8))
    data.append(contentsOf: Array("fmt ".utf8)); u32(16); u16(1); u16(1); u32(UInt32(sampleRate)); u32(UInt32(sampleRate * 2)); u16(2); u16(16)
    data.append(contentsOf: Array("data".utf8)); u32(UInt32(samples.count * 2))
    for sample in samples { u16(UInt16(bitPattern: sample)) }
    try! data.write(to: URL(fileURLWithPath: path))
}

func tone(_ frequency: Double, _ seconds: Double, _ volume: Double = 0.22, _ slide: Double = 0) -> [Int16] {
    let count = Int(Double(sampleRate) * seconds)
    return (0..<count).map { index in
        let t = Double(index) / Double(sampleRate)
        let progress = t / seconds
        let f = frequency + slide * progress
        let envelope = min(1, t * 70) * min(1, (seconds - t) * 18)
        let value = sin(t * f * 2 * .pi) * volume * envelope
        return Int16(max(-1, min(1, value)) * 32767)
    }
}

func chord(_ notes: [Double], _ seconds: Double, _ volume: Double = 0.16) -> [Int16] {
    let count = Int(Double(sampleRate) * seconds)
    return (0..<count).map { index in
        let t = Double(index) / Double(sampleRate)
        let envelope = min(1, t * 20) * min(1, (seconds - t) * 8)
        let value = notes.reduce(0.0) { $0 + sin(t * $1 * 2 * .pi) } / Double(notes.count)
        return Int16(value * volume * envelope * 32767)
    }
}

func sequence(_ parts: [[Int16]]) -> [Int16] { parts.flatMap { $0 } }

let files: [(String, [Int16])] = [
    ("jump.wav", sequence([tone(420, 0.08, 0.20, 180), tone(720, 0.07, 0.12)])),
    ("super_jump.wav", sequence([tone(360, 0.08, 0.2, 240), tone(660, 0.09, 0.16, 300), tone(960, 0.08, 0.12)])),
    ("land.wav", tone(115, 0.09, 0.25, -25)),
    ("pickup.wav", sequence([tone(720, 0.06, 0.16), tone(980, 0.08, 0.13)])),
    ("combo.wav", sequence([tone(600, 0.06, 0.13), tone(800, 0.06, 0.13), tone(1100, 0.1, 0.13)])),
    ("skill.wav", sequence([tone(330, 0.12, 0.15, 220), tone(880, 0.18, 0.13)])),
    ("checkpoint.wav", sequence([tone(440, 0.1, 0.16), tone(660, 0.1, 0.16), tone(880, 0.18, 0.14)])),
    ("area.wav", sequence([tone(520, 0.12, 0.14), tone(780, 0.14, 0.13)])),
    ("hit.wav", tone(100, 0.2, 0.3, -55)),
    ("revive.wav", sequence([tone(260, 0.12, 0.14, 180), tone(520, 0.16, 0.15)])),
    ("gameover.wav", sequence([tone(380, 0.14, 0.16, -80), tone(180, 0.24, 0.2, -40)])),
    ("win.wav", sequence([tone(523, 0.1, 0.14), tone(659, 0.1, 0.14), tone(784, 0.18, 0.16)])),
    ("click.wav", tone(880, 0.035, 0.12)),
]

for (name, samples) in files { writeWav(output + "/" + name, samples: samples) }

var music = [Int16]()
let notes: [Double] = [261.63, 329.63, 392.0, 523.25, 392.0, 329.63, 293.66, 392.0]
for note in notes { music += chord([note, note * 1.5], 0.42, 0.11); music += tone(note * 2, 0.1, 0.045) }
writeWav(output + "/bgm.wav", samples: music)
