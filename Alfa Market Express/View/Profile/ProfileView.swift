//
//  ProfileView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct ProfileView: View {
    @State private var selectedTab: Int = 0 // Индекс выбранной вкладки
    @ObservedObject var viewModel: MainViewModel // Модель представления для привязки данных

    var body: some View {
        VStack {
            // Заголовок с логотипом
            HeaderView {
                Image("logo_v1")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal)
            }
            // Кнопки навигации для выбора вкладок
            NavigationButtons(selectedTab: $selectedTab)
            // TabView для различных разделов
            TabView(selection: $selectedTab) {
                ProfileInfo(viewModel: viewModel) // Первая вкладка: Информация профиля
                    .tag(0)
                OrdersView(viewModel: viewModel) // Вторая вкладка: Заказы
                    .tag(1)
                EditProfile(viewModel: viewModel) // Третья вкладка: Редактировать профиль
                    .tag(2)
            }
        }
    }
}

// Кнопки навигации для выбора вкладок
struct NavigationButtons: View {
    @Binding var selectedTab: Int // Привязка к выбранному индексу вкладки

    var body: some View {
        HStack(spacing: 10) {
            NavigationButton(title: "Профиль", tabIndex: 0, selectedTab: $selectedTab)
            NavigationButton(title: "Мои заказы", tabIndex: 1, selectedTab: $selectedTab)
            NavigationButton(title: "Редактировать", tabIndex: 2, selectedTab: $selectedTab)
        }
        .padding(.vertical, 15) // Вертикальные отступы для кнопок
    }
}

// Индивидуальная кнопка навигации
struct NavigationButton: View {
    let title: String // Заголовок кнопки
    let tabIndex: Int // Индекс соответствующей вкладки
    @Binding var selectedTab: Int // Привязка к выбранному индексу вкладки

    var body: some View {
        Button(action: {
            // Изменяем выбранную вкладку, когда кнопка нажата
            selectedTab = tabIndex
        }) {
            Text(title)
                .bold()
                .padding(.vertical, 10)
                .padding(.horizontal, 5)
                .background(selectedTab == tabIndex ? .colorGreen : Color.clear) // Подсветка выбранной вкладки
                .foregroundColor(selectedTab == tabIndex ? .white : .black)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.colorGreen, lineWidth: 1)) // Граница для кнопки
        }
    }
}

// Превью для ProfileView
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel()) // Предоставляем экземпляр MainViewModel для превью
    }
}
