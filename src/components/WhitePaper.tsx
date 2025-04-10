import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  font-family: "Bradley DJR Variable", sans-serif;
  background-image: url('/logo1.jpeg');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  color: white;
  text-shadow: 2px 2px 4px black;
  width: 100%;
  max-width: 900px;
  margin: 24px auto;
  padding: var(--padding);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow);
`;

const Title = styled.h1`
  text-align: center;
  font-size: 2.2rem;
  margin-bottom: 2rem;
`;

const Section = styled.section`
  margin-bottom: 2rem;
`;

const SectionTitle = styled.h2`
  font-size: 1.6rem;
  margin-bottom: 1rem;
`;

const Paragraph = styled.p`
  font-size: 2rem;
  margin-bottom: 1rem;
  line-height: 1.5;
`;

const List = styled.ul`
  margin-left: 1.5rem;
  margin-bottom: 1rem;
  list-style: disc;

  li {
    margin-bottom: 0.5rem;
  }
`;

const WhitePaper: React.FC = () => (
  <Container>
    <Title>Capsule Protocol: Identity, Memory, Legacy & Privacy on Chain</Title>

    <Section>
      <SectionTitle>Abstract</SectionTitle>
      <Paragraph>
        The <strong>Capsule Protocol</strong> is a modular, sovereign identity system built on programmable capsules. Each capsule is a tokenized container for user-controlled logic, linked wallets, oracle drones, encrypted data, and legacy transfers — all operating in a decentralized, trustless network.
      </Paragraph>
      <Paragraph>
        This white paper outlines the structure and use cases of the protocol’s four core modules: Coincapsule, Privacy, Legacy, and Timeline. These form the foundation for personal sovereignty in Web3 — enabling identity, storage, death protocols, and historical continuity.
      </Paragraph>
    </Section>

    <Section>
      <SectionTitle>1. Introduction</SectionTitle>
      <Paragraph>
        In Web3, there is no native identity, no native privacy, and no native succession. Capsule Protocol introduces capsules — programmable, tokenized identities that integrate directly with wallets, oracles, agents, and time-based functions.
      </Paragraph>
      <List>
        <li>Mint identity capsules that link to wallets and oracles.</li>
        <li>Store encrypted content (like IPFS URIs) tied to capsules.</li>
        <li>Assign on-chain legacy claims (wills) via time locks.</li>
        <li>Chain capsule events together into timelines or narratives.</li>
      </List>
    </Section>

    <Section>
      <SectionTitle>2. Core Modules</SectionTitle>
      <SectionTitle>2.1 Coincapsule</SectionTitle>
      <Paragraph>
        The entry point. Mints capsule tokens that spawn a smart wallet and an oracle drone. Each capsule acts as a programmable identity object.
      </Paragraph>

      <SectionTitle>2.2 Privacy Module</SectionTitle>
      <Paragraph>
        Allows capsule owners to attach encrypted URIs. These can point to secure documents, logs, data, or communications. Decryption is permission-based.
      </Paragraph>

      <SectionTitle>2.3 Legacy Module</SectionTitle>
      <Paragraph>
        Enables time-locked inheritance. Owners can assign a future beneficiary, unlocking after a set period. On-chain wills for crypto natives.
      </Paragraph>

      <SectionTitle>2.4 Timeline Module</SectionTitle>
      <Paragraph>
        Connect capsules together across time, creating branching or linear storylines, public chains of memory, or verified event logs.
      </Paragraph>
    </Section>

    <Section>
      <SectionTitle>3. Use Cases</SectionTitle>
      <List>
        <li>Tokenized identity and wallet creation (per capsule).</li>
        <li>Private storage of encrypted files, logs, or documents.</li>
        <li>Inheritance protocol for DAOs, creators, and families.</li>
        <li>Historical preservation and storytelling on-chain.</li>
      </List>
    </Section>

    <Section>
      <SectionTitle>4. Security & Access Control</SectionTitle>
      <Paragraph>
        Capsules use Merkle-based proofs and smart contract permissions to manage ownership, control, and access. The Privacy Module restricts URI access to authorized decryptors.
      </Paragraph>
      <List>
        <li>Role-based execution and signature verification.</li>
        <li>Merkle root authorization via ModularExecutor.</li>
        <li>Capsule freeze/unfreeze options (password locked).</li>
      </List>
    </Section>

    <Section>
      <SectionTitle>5. Governance and Extensions</SectionTitle>
      <Paragraph>
        Capsules are modular. The ModularExecutor allows additional logic (like swap modules, DAO plugins, AI agents) to be attached to any capsule. DAO control of capsule behavior is possible via Merkle signatures.
      </Paragraph>
    </Section>

    <Section>
      <SectionTitle>6. Roadmap</SectionTitle>
      <List>
        <li><strong>Phase 1:</strong> Coincapsule + Legacy + Privacy modules live</li>
        <li><strong>Phase 2:</strong> Timeline explorer + inheritance marketplace</li>
        <li><strong>Phase 3:</strong> Capsule Agents + Modular Executor extensions</li>
      </List>
    </Section>
  </Container>
);

export default WhitePaper;