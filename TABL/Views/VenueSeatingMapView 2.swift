import SwiftUI

struct VenueTable: Identifiable {
    let id = UUID()
    let number: Int
    let position: CGPoint
    let price: Double
    var isBooked: Bool
    let capacity: Int
}

struct VenueSeatingMapView: View {
    @State private var selectedTable: VenueTable?
    @State private var hoveredTable: VenueTable?
    @State private var tables: [VenueTable] = []
    @State private var hoverLocation: CGPoint = .zero
    
    init() {
        _tables = State(initialValue: createTablesFromImage())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image from assets
                Image("Sound-Table-Chart-24")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Interactive overlay for table numbers
                ForEach(tables) { table in
                    InteractiveTableArea(
                        table: table,
                        isHovered: hoveredTable?.id == table.id,
                        isSelected: selectedTable?.id == table.id,
                        geometry: geometry
                    )
                    .position(
                        x: geometry.size.width * table.position.x,
                        y: geometry.size.height * table.position.y
                    )
                    .onHover { isHovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isHovering {
                                hoveredTable = table
                                hoverLocation = CGPoint(
                                    x: geometry.size.width * table.position.x,
                                    y: geometry.size.height * table.position.y
                                )
                            } else if hoveredTable?.id == table.id {
                                hoveredTable = nil
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            if !table.isBooked {
                                selectedTable = table
                            }
                        }
                    }
                }
                
                // Hover tooltip
                if let hovered = hoveredTable {
                    HoverTooltip(table: hovered)
                        .position(x: hoverLocation.x, y: hoverLocation.y - 60)
                        .zIndex(1)
                }
                
                // Purchase popup
                if let selected = selectedTable {
                    PurchasePopup(table: selected) {
                        purchaseTable(selected)
                    } onCancel: {
                        withAnimation {
                            selectedTable = nil
                        }
                    }
                    .zIndex(2)
                }
            }
        }
        .background(Color.black)
    }
    
    // Create tables based on typical seating chart positions
    // You'll need to adjust these coordinates to match your specific image
    func createTablesFromImage() -> [VenueTable] {
        var allTables: [VenueTable] = []
        
        // These coordinates are estimated - you'll need to adjust them
        // based on where the numbers appear in your "Sound-Table-Chart-24" image
        
        // Top row tables (adjust positions based on your image)
        let topTables = [
            (number: 21, x: 0.2, y: 0.15, price: 1200.0),
            (number: 22, x: 0.3, y: 0.15, price: 1300.0),
            (number: 23, x: 0.4, y: 0.15, price: 1400.0),
            (number: 24, x: 0.5, y: 0.15, price: 1500.0),
            (number: 25, x: 0.6, y: 0.15, price: 1300.0),
            (number: 26, x: 0.7, y: 0.15, price: 1200.0)
        ]
        
        for table in topTables {
            allTables.append(VenueTable(
                number: table.number,
                position: CGPoint(x: table.x, y: table.y),
                price: table.price,
                isBooked: Bool.random(),
                capacity: 8
            ))
        }
        
        // Middle row tables
        let middleTables = [
            (number: 11, x: 0.2, y: 0.35, price: 900.0),
            (number: 12, x: 0.3, y: 0.35, price: 950.0),
            (number: 13, x: 0.4, y: 0.35, price: 1000.0),
            (number: 14, x: 0.5, y: 0.35, price: 1000.0),
            (number: 15, x: 0.6, y: 0.35, price: 950.0),
            (number: 16, x: 0.7, y: 0.35, price: 900.0)
        ]
        
        for table in middleTables {
            allTables.append(VenueTable(
                number: table.number,
                position: CGPoint(x: table.x, y: table.y),
                price: table.price,
                isBooked: Bool.random(),
                capacity: 6
            ))
        }
        
        // Bottom tables
        let bottomTables = [
            (number: 1, x: 0.7, y: 0.75, price: 600.0),
            (number: 2, x: 0.5, y: 0.75, price: 650.0),
            (number: 3, x: 0.3, y: 0.75, price: 600.0)
        ]
        
        for table in bottomTables {
            allTables.append(VenueTable(
                number: table.number,
                position: CGPoint(x: table.x, y: table.y),
                price: table.price,
                isBooked: Bool.random(),
                capacity: 6
            ))
        }
        
        // Side tables
        allTables.append(VenueTable(number: 17, position: CGPoint(x: 0.1, y: 0.4), price: 700, isBooked: false, capacity: 4))
        allTables.append(VenueTable(number: 4, position: CGPoint(x: 0.1, y: 0.6), price: 500, isBooked: false, capacity: 4))
        
        return allTables
    }
    
    func purchaseTable(_ table: VenueTable) {
        withAnimation {
            if let index = tables.firstIndex(where: { $0.id == table.id }) {
                tables[index].isBooked = true
            }
            selectedTable = nil
        }
    }
}

// Interactive area that detects hover and clicks
struct InteractiveTableArea: View {
    let table: VenueTable
    let isHovered: Bool
    let isSelected: Bool
    let geometry: GeometryProxy
    
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(isHovered ? Color.yellow : Color.clear, lineWidth: 3)
                    .scaleEffect(isHovered ? 1.2 : 1.0)
            )
            .scaleEffect(isSelected ? 1.3 : 1.0)
    }
}

// Hover tooltip that shows when mouse is over a table
struct HoverTooltip: View {
    let table: VenueTable
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Table \(table.number)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("$\(Int(table.price))")
                .font(.title2)
                .bold()
                .foregroundColor(.green)
            
            Text("\(table.capacity) seats")
                .font(.caption)
                .foregroundColor(.gray)
            
            if table.isBooked {
                Text("BOOKED")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(4)
            } else {
                Button("Buy Now") {
                    // This will be handled by the tap gesture on the main view
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(6)
                .font(.caption)
                .bold()
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.9))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        .transition(.opacity.combined(with: .scale))
    }
}

// Purchase confirmation popup
struct PurchasePopup: View {
    let table: VenueTable
    let onPurchase: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                Text("Purchase Table \(table.number)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Capacity:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(table.capacity) people")
                            .foregroundColor(.white)
                            .bold()
                    }
                    
                    HStack {
                        Text("Price:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("$\(Int(table.price))")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                        .background(Color.gray)
                    
                    Text("This purchase includes reserved seating for your party and bottle service.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("Confirm Purchase") {
                        onPurchase()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .bold()
                }
            }
            .padding(32)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            .frame(maxWidth: 400)
        }
    }
}

#Preview {
    VenueSeatingMapView()
}