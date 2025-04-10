import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  max-width: 800px;
  margin: 40px auto;
  padding: 20px;
  color: #fff;
  background-color: #121212;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  font-family: "Arial", sans-serif;
`;

const Title = styled.h1`
  font-size: 32px;
  margin-bottom: 20px;
  text-align: center;
  color: #4caf50;
`;

const Section = styled.section`
  margin-bottom: 30px;
`;

const SectionTitle = styled.h2`
  font-size: 24px;
  margin-bottom: 10px;
  color: #ff9800;
`;

const Paragraph = styled.p`
  font-size: 16px;
  line-height: 1.6;
`;

const InstructionList = styled.ul`
  list-style: disc;
  margin-left: 20px;
  font-size: 16px;
  line-height: 1.6;
`;

const InstructionPage: React.FC = () => {
  return (
    <Container>
      <Title>Capsule Protocol Interaction Instructions</Title>

      <Section>
        <SectionTitle>Introduction</SectionTitle>
        <Paragraph>
          Capsule Protocol provides an interface to mint capsule identities, manage encrypted files, assign heirs, and link on-chain timelines. These instructions guide you through every module.
        </Paragraph>
      </Section>

      <Section>
        <SectionTitle>1️⃣ Connecting Your Wallet</SectionTitle>
        <Paragraph>
          Click <strong>“Connect Wallet”</strong> to begin. Use MetaMask or any EVM-compatible wallet and ensure you're on the correct network.
        </Paragraph>
      </Section>

      <Section>
        <SectionTitle>2️⃣ Minting Your Capsule</SectionTitle>
        <InstructionList>
          <li>Open the <strong>Mint Capsule</strong> screen.</li>
          <li>Choose how many capsules to mint and set an optional label.</li>
          <li>Each capsule mints with a wallet and linked oracle drone.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>3️⃣ Using Privacy Module</SectionTitle>
        <InstructionList>
          <li>Navigate to <strong>Capsule Privacy</strong>.</li>
          <li>Paste an encrypted IPFS or Arweave URI.</li>
          <li>Set the address allowed to decrypt the content.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>4️⃣ Assigning a Legacy Heir</SectionTitle>
        <InstructionList>
          <li>Go to the <strong>Legacy Module</strong>.</li>
          <li>Enter the capsule ID, heir address, and unlock time (in seconds).</li>
          <li>Once unlocked, the heir can claim the capsule on-chain.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>5️⃣ Linking Timelines</SectionTitle>
        <InstructionList>
          <li>Open the <strong>Timeline Module</strong>.</li>
          <li>Choose a capsule and link it to a parent capsule.</li>
          <li>Add a tag like “Season 1”, “Post”, or “Chapter”.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>🧠 Adding Capsule Modules</SectionTitle>
        <InstructionList>
          <li>Use the <strong>ModularExecutor</strong> to install features like DeFi swaps, bots, or governance tools to any capsule.</li>
          <li>Verify Merkle proof or signature to authorize new module execution.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>📞 Need Help?</SectionTitle>
        <InstructionList>
          <li>Check your network and wallet connection.</li>
          <li>Ensure your capsule exists and isn’t frozen.</li>
          <li>Join our support on Telegram, Discord, or Twitter.</li>
        </InstructionList>
      </Section>
    </Container>
  );
};

export default InstructionPage;