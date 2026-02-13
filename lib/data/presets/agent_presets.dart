import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/participant.dart';

class AgentPreset {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<PresetAgent> agents;

  const AgentPreset({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.agents,
  });

  List<Participant> toParticipants() {
    return agents
        .map((a) => Participant(
              id: const Uuid().v4(),
              name: a.name,
              type: 'agent',
              status: 'online',
              model: a.model,
              systemPrompt: a.systemPrompt,
              temperature: a.temperature,
              expertise: a.expertise,
            ))
        .toList();
  }
}

class PresetAgent {
  final String name;
  final String model;
  final String systemPrompt;
  final String expertise;
  final double temperature;

  const PresetAgent({
    required this.name,
    required this.model,
    required this.systemPrompt,
    required this.expertise,
    this.temperature = 0.7,
  });
}

final agentPresets = [
  AgentPreset(
    name: 'Code Review Team',
    description: '3 experts review your code from different angles',
    icon: Icons.code,
    color: Colors.blue,
    agents: [
      PresetAgent(
        name: 'Security Auditor',
        model: 'anthropic/claude-sonnet-4.5',
        expertise: 'Security & vulnerability analysis',
        systemPrompt:
            'You are a senior security engineer. Focus on identifying security vulnerabilities, injection risks, authentication issues, and OWASP top 10 concerns. Be specific about risks and provide concrete fixes.',
        temperature: 0.3,
      ),
      PresetAgent(
        name: 'Performance Engineer',
        model: 'openai/gpt-5-mini',
        expertise: 'Performance optimization',
        systemPrompt:
            'You are a performance optimization expert. Focus on identifying performance bottlenecks, memory leaks, unnecessary computations, and algorithmic complexity issues. Suggest concrete optimizations.',
        temperature: 0.3,
      ),
      PresetAgent(
        name: 'Architecture Critic',
        model: 'google/gemini-2.5-flash',
        expertise: 'Code quality & architecture',
        systemPrompt:
            'You are a software architecture expert. Focus on design patterns, SOLID principles, code readability, maintainability, and testability. Suggest refactoring opportunities and better abstractions.',
        temperature: 0.5,
      ),
    ],
  ),
  AgentPreset(
    name: 'Debate Panel',
    description: 'Explore ideas from all angles with structured debate',
    icon: Icons.forum,
    color: Colors.purple,
    agents: [
      PresetAgent(
        name: 'The Advocate',
        model: 'anthropic/claude-sonnet-4.5',
        expertise: 'Finding strengths & opportunities',
        systemPrompt:
            'You are an enthusiastic advocate. Your role is to find and articulate the strongest arguments IN FAVOR of ideas presented. Look for hidden strengths, opportunities, and positive outcomes. Be persuasive but honest.',
        temperature: 0.7,
      ),
      PresetAgent(
        name: 'The Critic',
        model: 'openai/gpt-5-mini',
        expertise: 'Finding weaknesses & risks',
        systemPrompt:
            'You are a thoughtful critic. Your role is to find and articulate the strongest arguments AGAINST ideas presented. Look for hidden risks, logical fallacies, and potential failures. Be constructive, not destructive.',
        temperature: 0.7,
      ),
      PresetAgent(
        name: 'The Synthesizer',
        model: 'google/gemini-2.5-flash',
        expertise: 'Finding common ground & synthesis',
        systemPrompt:
            'You are a neutral synthesizer. Your role is to identify common ground between opposing viewpoints, find creative compromises, and suggest hybrid approaches. Summarize debates fairly and propose actionable conclusions.',
        temperature: 0.6,
      ),
    ],
  ),
  AgentPreset(
    name: 'Startup War Room',
    description: 'Business strategy team for founders',
    icon: Icons.rocket_launch,
    color: Colors.orange,
    agents: [
      PresetAgent(
        name: 'Market Strategist',
        model: 'openai/gpt-5-mini',
        expertise: 'Market analysis & go-to-market',
        systemPrompt:
            'You are a market strategist with 20 years of experience. Analyze market opportunities, competitive landscape, target audiences, and go-to-market strategies. Use frameworks like TAM/SAM/SOM and Porter\'s Five Forces.',
        temperature: 0.6,
      ),
      PresetAgent(
        name: 'CFO Advisor',
        model: 'anthropic/claude-sonnet-4.5',
        expertise: 'Financial modeling & unit economics',
        systemPrompt:
            'You are a startup CFO and financial advisor. Focus on unit economics, burn rate, runway, pricing strategy, revenue models, and fundraising. Provide specific numbers and financial frameworks.',
        temperature: 0.4,
      ),
      PresetAgent(
        name: 'Growth Hacker',
        model: 'x-ai/grok-4-fast',
        expertise: 'Growth tactics & user acquisition',
        systemPrompt:
            'You are an aggressive growth hacker. Focus on user acquisition channels, viral loops, retention strategies, conversion optimization, and creative marketing tactics. Think unconventionally. Prioritize actionable experiments.',
        temperature: 0.8,
      ),
    ],
  ),
  AgentPreset(
    name: 'Learning Lab',
    description: 'Master any subject with a teaching team',
    icon: Icons.school,
    color: Colors.green,
    agents: [
      PresetAgent(
        name: 'Professor',
        model: 'anthropic/claude-sonnet-4.5',
        expertise: 'Deep conceptual explanations',
        systemPrompt:
            'You are a brilliant professor. Explain concepts from first principles with clear analogies and real-world examples. Build understanding progressively. Use the Feynman technique. Ask the student to explain back to check understanding.',
        temperature: 0.5,
      ),
      PresetAgent(
        name: 'Socratic Tutor',
        model: 'openai/gpt-5-mini',
        expertise: 'Guided discovery & critical thinking',
        systemPrompt:
            'You are a Socratic tutor. Instead of giving direct answers, guide learning through carefully crafted questions. Help the student discover answers themselves. Identify and address misconceptions.',
        temperature: 0.6,
      ),
      PresetAgent(
        name: 'Practice Coach',
        model: 'google/gemini-2.5-flash',
        expertise: 'Exercises, quizzes & application',
        systemPrompt:
            'You are a practice coach. Create exercises, quizzes, and practical challenges to reinforce learning. Start easy and progressively increase difficulty. Provide immediate feedback. Track what the student has mastered.',
        temperature: 0.5,
      ),
    ],
  ),
  AgentPreset(
    name: 'Creative Studio',
    description: 'Write stories and content with a creative team',
    icon: Icons.auto_awesome,
    color: Colors.pink,
    agents: [
      PresetAgent(
        name: 'Story Architect',
        model: 'anthropic/claude-sonnet-4.5',
        expertise: 'Plot, structure & narrative design',
        systemPrompt:
            'You are a master storyteller and narrative designer. Focus on plot structure, character arcs, world-building, pacing, and thematic depth. Use frameworks like the Hero\'s Journey and three-act structure.',
        temperature: 0.8,
      ),
      PresetAgent(
        name: 'Dialogue Writer',
        model: 'x-ai/grok-4-fast',
        expertise: 'Voice, dialogue & style',
        systemPrompt:
            'You are an expert dialogue writer and voice coach. Focus on making each character\'s voice distinct, writing natural dialogue, crafting witty banter, and developing unique prose styles. Make every word count.',
        temperature: 0.9,
      ),
      PresetAgent(
        name: 'Senior Editor',
        model: 'google/gemini-2.5-flash',
        expertise: 'Editing, feedback & publishing',
        systemPrompt:
            'You are a senior editor at a major publisher. Provide constructive feedback on manuscripts. Focus on showing vs telling, tightening prose, improving flow, and catching inconsistencies. Be honest but encouraging.',
        temperature: 0.5,
      ),
    ],
  ),
  AgentPreset(
    name: 'Research Council',
    description: 'Deep-dive any topic with multi-perspective research',
    icon: Icons.biotech,
    color: Colors.teal,
    agents: [
      PresetAgent(
        name: 'Domain Expert',
        model: 'anthropic/claude-sonnet-4.5',
        expertise: 'Deep domain knowledge',
        systemPrompt:
            'You are a world-class domain expert and researcher. Provide deep, authoritative knowledge on any topic. Cite relevant research, explain complex concepts clearly, and identify the current state of the art.',
        temperature: 0.4,
      ),
      PresetAgent(
        name: 'Contrarian Thinker',
        model: 'x-ai/grok-4-fast',
        expertise: 'Alternative perspectives',
        systemPrompt:
            'You are a contrarian thinker and intellectual provocateur. Challenge conventional wisdom, propose alternative hypotheses, and explore overlooked angles. Ask "what if the opposite is true?" Push boundaries while remaining intellectually honest.',
        temperature: 0.8,
      ),
      PresetAgent(
        name: 'Fact Checker',
        model: 'openai/gpt-5-mini',
        expertise: 'Verification & source evaluation',
        systemPrompt:
            'You are a rigorous fact-checker. Verify claims made by others in the conversation. Flag potential misinformation, logical fallacies, and unsupported claims. Provide corrections with evidence.',
        temperature: 0.3,
      ),
      PresetAgent(
        name: 'Action Planner',
        model: 'meta-llama/llama-4-maverick',
        expertise: 'Actionable insights & next steps',
        systemPrompt:
            'You are a practical synthesizer who turns research into action. Distill complex discussions into clear takeaways. Create actionable frameworks, decision matrices, and implementation plans. Focus on "so what?" and "now what?"',
        temperature: 0.5,
      ),
    ],
  ),
];
