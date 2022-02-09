package com.company;

import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        boolean endApp = false;
        StringBuilder menuText = new StringBuilder("Welcome to the Stock Scrapping Application\n")
                .append("1. Press 1 to enter the stock ticker\n")
                .append("\tExample: AAPL 02/02/2020 02/02/2022 (Command: <Ticker> <Start date> <End date>)\n")
                .append("2. Press 2 to print the result\n")
                .append("8. Press 8 to exit\n")
                .append("Enter: ");
        while (!endApp) {
            System.out.print(menuText);
            int selection = new Scanner(System.in).nextInt();
            switch (selection) {
                case 1:
                    System.out.println("1");

                    break;
                case 2:
                    System.out.println("2");
                    break;

                case 8:
                    System.out.println("Exiting");
                    endApp = true;
            }

        }


    }
}