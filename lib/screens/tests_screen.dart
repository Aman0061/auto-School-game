import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../models/ticket.dart';
import '../models/module.dart';
import 'quiz_screen.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketProvider>(context, listen: false).loadTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Тесты',
          style: TextStyle(
            color: Color(0xFF0D1C0D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C0D),
        elevation: 0,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          if (ticketProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final tickets = ticketProvider.tickets;
          final medicalTickets = ticketProvider.medicalTickets;
          final allTickets = [...tickets, ...medicalTickets];
          final completedTickets = ticketProvider.getCompletedTicketsCount();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Прогресс
                Text(
                  'Завершено $completedTickets из ${allTickets.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Прогресс бар
                LinearProgressIndicator(
                  value: completedTickets / allTickets.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF019863)),
                  minHeight: 8,
                ),
                
                const SizedBox(height: 24),
                
                // Заголовок
                const Text(
                  'Выберите билет',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Сетка билетов
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = allTickets[index];
                    return _buildTicketCard(ticket);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final isCompleted = ticketProvider.isTicketCompleted(ticket.id);
    final isFailed = ticketProvider.isTicketFailed(ticket.id);
    
    // Определяем цвет карточки
    Color cardColor;
    if (isCompleted) {
      cardColor = const Color(0xFF019863); // Зеленый для завершенных
    } else if (isFailed) {
      cardColor = const Color(0xFFE74C3C); // Красный для проваленных
    } else if (ticket.isMedical) {
      cardColor = const Color(0xFFE74C3C); // Красный для медицинского
    } else {
      cardColor = const Color(0xFFFAC638); // Желтый для обычных билетов
    }
    
    return GestureDetector(
      onTap: () => _startTicket(ticket),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Номер билета в квадрате
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  ticket.isMedical ? 'М' : ticket.title.split(' ').last,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Название билета
            Text(
              ticket.isMedical ? 'Медицинский' : 'Билет ${ticket.title.split(' ').last}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D1C0D),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // Количество вопросов
            Text(
              '${ticket.questionCount} вопросов',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startTicket(Ticket ticket) async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    if (ticket.isMedical) {
      ticketProvider.startMedicalTicket();
    } else {
      ticketProvider.startTicket(ticket.id);
    }
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(module: Module(
            id: ticket.id,
            title: ticket.title,
            description: ticket.description,
            questionCount: ticket.questionCount,
            isExam: false,
          )),
        ),
      );
    }
  }
}
